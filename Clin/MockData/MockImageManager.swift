//
//  MockImageManager.swift
//  Clin
//
//  Created by asia on 17/08/2024.
//

import SwiftUI
import PhotosUI

struct MockImageManager: ImageManagerProtocol {
    var isHeicSupported: Bool
    
    func analyzeImage(_ data: Data) async -> AnalysisState {
        return AnalysisState.analyzing
    }
    
    func uploadImage(_ data: Data, from bucket: String, to folder: String, targetWidth: Int, targetHeight: Int, compressionQuality: CGFloat) async throws -> String? {
        return nil
    }
    
    func deleteImage(path: String, from folder: String) async throws {
        
    }
    
    func loadItem(item: PhotosPickerItem, analyze: Bool) async -> ImageLoadResult {
        return ImageLoadResult.sensitiveContent
    }
}
