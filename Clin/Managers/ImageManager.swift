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
    
    func uploadImage(_ data: Data, to folder: String, compressionQuality: CGFloat = 0.1) async throws -> String? {
        guard let compressedData = compressImage(data: data, compressionQuality: compressionQuality) else {
            print("Failed to compress image.")
            return nil
        }
        
        let filePath = "\(UUID().uuidString).jpeg"
        
        try await supabase.storage
            .from(folder)
            .upload(
                path: filePath,
                file: compressedData,
                options: FileOptions(contentType: "image/jpeg")
            )
        
        print("Image uploaded to Supabase Storage at path: \(filePath)")
        
        let url = try supabase.storage.from(folder).getPublicURL(path: filePath, download: true)
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
    
    private func compressImage(data: Data, compressionQuality: CGFloat) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        return image.jpegData(compressionQuality: compressionQuality)
    }
}

