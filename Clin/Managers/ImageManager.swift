//
//  ImageService.swift
//  Clin
//
//  Created by asia on 08/07/2024.
//

import SwiftUI
import PhotosUI
import Storage
import Factory

enum ImageLoadResult {
    case success(SelectedImage)
    case sensitiveContent
    case analysisError(String)
    case loadingError(String)
}

final class ImageManager: ImageManagerProtocol {
    @Injected(\.supabaseService) private var supabaseService
    
    var isHeicSupported: Bool {
        (CGImageDestinationCopyTypeIdentifiers() as! [String]).contains("public.heic")
    }
    
    func analyzeImage(_ data: Data) async -> AnalysisState {
        await SensitiveContentAnalysis.shared.analyze(image: data)
        return SensitiveContentAnalysis.shared.analysisState
    }
    
    func uploadImage(_ data: Data, from bucket: String, to folder: String, targetWidth: Int, targetHeight: Int, compressionQuality: CGFloat = 0.1) async throws -> String? {
        guard let uiImage = UIImage(data: data) else {
            print("DEBUG: Failed to create UIImage from data.")
            return nil
        }
        
        let resizedImage: UIImage
        if let resized = uiImage.resize(targetWidth, targetHeight) {
            resizedImage = resized
        } else {
            print("DEBUG: Failed to resize image.")
            return nil
        }
        
        let compressedData: Data?
        let filePath: String
        let contentType: String
        
        if isHeicSupported {
            compressedData = resizedImage.heicData(compressionQuality: compressionQuality)
            filePath = "\(folder)/\(UUID().uuidString).heic"
            contentType = "image/heic"
            print("DEBUG: HEIC is supported.")
        } else {
            compressedData = resizedImage.jpegData(compressionQuality: compressionQuality)
            filePath = "\(folder)/\(UUID().uuidString).jpeg"
            contentType = "image/jpeg"
            print("DEBUG: JPEG is supported.")
        }
      
        guard let finalData = compressedData else {
            print("DEBUG: Failed to compress image.")
            return nil
        }
        
        try await supabaseService.client.storage
            .from(bucket)
            .upload(
                path: filePath,
                file: finalData,
                options: FileOptions(contentType: contentType)
            )
        
        print("DEBUG: Image uploaded to Supabase Storage at path: \(filePath)")
        
        let url = try supabaseService.client.storage.from(bucket).getPublicURL(path: filePath, download: true)
        return url.absoluteString
    }
    
    func deleteImage(path: String, from folder: String) async throws {
        do {
            let fileName = URL(string: path)?.lastPathComponent ?? ""
            _ = try await supabaseService.client.storage.from(folder).remove(paths: [fileName])
            print("DEBUG: Image deleted from Supabase Storage at path: \(path)")
        } catch {
            print("DEBUG: Error deleting image from database: \(error)")
            throw error
        }
    }
    
    func loadItem(item: PhotosPickerItem, analyze: Bool = true) async -> ImageLoadResult {
        do {
            let data = try await item.loadTransferable(type: Data.self)
            guard let data = data else {
                return .loadingError("No data was returned from the PhotosPickerItem.")
            }

            guard UIImage(data: data) != nil else {
                return .loadingError("Data could not be converted to UIImage.")
            }

            if analyze {
                let analysisState = await analyzeImage(data)
                switch analysisState {
                case .isSensitive:
                    return .sensitiveContent
                case .error(let message):
                    return .analysisError(message)
                default:
                    break
                }
            }

            guard let selectedImage = SelectedImage(data: data, photosPickerItem: nil) else {
                return .loadingError("Failed to create SelectedImage from data.")
            }
            
            return .success(selectedImage)
        } catch {
            return .loadingError(error.localizedDescription)
        }
    }
}

