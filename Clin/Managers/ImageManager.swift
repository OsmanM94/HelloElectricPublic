//
//  ImageService.swift
//  Clin
//
//  Created by asia on 08/07/2024.
//

import Foundation
import SwiftUI
import PhotosUI
import Storage


final class ImageManager {
    static let shared = ImageManager()
    
    private init() {}
    
    func analyzeImage(_ data: Data) async -> AnalysisState {
        await SensitiveContentAnalysis.shared.analyze(image: data)
        return SensitiveContentAnalysis.shared.analysisState
    }
    
    func uploadImage(_ data: Data,from bucket: String ,to folder: String, targetWidth: Int, targetHeight: Int, compressionQuality: CGFloat = 0.1) async throws -> String? {
        
        guard let uiImage = UIImage(data: data) else {
            print("DEBUG: Failed to create UIImage from data.")
            return nil
        }
                
        guard let resizedImage = uiImage.resize(targetWidth, targetHeight) else {
            print("DEBUG: Failed to resize image.")
            return nil
        }
        
        guard let resizedData = resizedImage.jpegData(compressionQuality: 1.0) else {
            print("DEBUG: Failed to convert resized image to data.")
            return nil
        }
        
        // Compress the resized image
        guard let compressedData = compressImage(data: resizedData, compressionQuality: compressionQuality) else {
            print("DEBUG: Failed to compress image.")
            return nil
        }
        
        let filePath = "\(folder)/\(UUID().uuidString).jpeg"
        try await Supabase.shared.client.storage
            .from(bucket)
            .upload(
                path: filePath,
                file: compressedData,
                options: FileOptions(contentType: "image/jpeg")
            )
        
        print("DEBUG: Image uploaded to Supabase Storage at path: \(filePath)")
        
        let url = try Supabase.shared.client.storage.from(bucket).getPublicURL(path: filePath, download: true)
        return url.absoluteString
    }
    
    func deleteImage(path: String, from folder: String) async throws {
        do {
            let fileName = URL(string: path)?.lastPathComponent ?? ""
            _ = try await Supabase.shared.client.storage.from(folder).remove(paths: [fileName])
            print("DEBUG: Image deleted from Supabase Storage at path: \(path)")
        } catch {
            print("DEBUG: Error deleting image from database: \(error)")
            throw error
        }
    }
    
    func loadItem(item: PhotosPickerItem, analyze: Bool = true) async -> PickedImage? {
        do {
            let data = try await item.loadTransferable(type: Data.self)
            guard let data = data, UIImage(data: data) != nil else { return nil }
            
            if analyze {
                let analysisState = await analyzeImage(data)
                switch analysisState {
                case .isSensitive, .error:
                    print("DEBUG: Image contains sensitive content or there was an error analyzing the image.")
                    return nil
                default:
                    break
                }
            }
            return PickedImage(data: data)
        } catch {
            print("DEBUG: Error loading image: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func compressImage(data: Data, compressionQuality: CGFloat) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        return image.jpegData(compressionQuality: compressionQuality)
    }
}


