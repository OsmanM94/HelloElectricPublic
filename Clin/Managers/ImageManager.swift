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
    private let supabase = SupabaseService.shared.client
    private let contentAnalyzer = SensitiveContentAnalysis.shared
    
    private init() {}
    
    func analyzeImage(_ data: Data) async -> AnalysisState {
        await contentAnalyzer.analyze(image: data)
        return contentAnalyzer.analysisState
    }
    
    func uploadImage(_ data: Data,from bucket: String ,to folder: String, compressionQuality: CGFloat = 0.1) async throws -> String? {
        guard let compressedData = compressImage(data: data, compressionQuality: compressionQuality) else {
            print("Failed to compress image.")
            return nil
        }
        
        let filePath = "\(folder)/\(UUID().uuidString).jpeg"
        try await supabase.storage
            .from(bucket)
            .upload(
                path: filePath,
                file: compressedData,
                options: FileOptions(contentType: "image/jpeg")
            )
        
        print("Image uploaded to Supabase Storage at path: \(filePath)")
        
        let url = try supabase.storage.from(bucket).getPublicURL(path: filePath, download: true)
        return url.absoluteString
    }
    
    func deleteImage(path: String, from folder: String) async throws {
        do {
            let fileName = URL(string: path)?.lastPathComponent ?? ""
            _ = try await supabase.storage.from(folder).remove(paths: [fileName])
            print("Image deleted from Supabase Storage at path: \(path)")
        } catch {
            print("Error deleting image from database: \(error)")
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
                    print("Image contains sensitive content or there was an error analyzing the image.")
                    return nil
                default:
                    break
                }
            }
            
            print("Image loaded and analyzed from PhotosPicker")
            return PickedImage(data: data)
        } catch {
            print("Error loading image: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func compressImage(data: Data, compressionQuality: CGFloat) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        return image.jpegData(compressionQuality: compressionQuality)
    }
    
}

