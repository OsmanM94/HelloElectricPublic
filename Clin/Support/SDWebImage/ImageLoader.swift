//
//  ImageLoader.swift
//  Clin
//
//  Created by asia on 30/06/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImageLoader: View {
    let url: URL
    var contentMode: ContentMode = .fill
    var targetSize: CGSize
    
    var body: some View {
       Rectangle()
            .opacity(0)
            .overlay {
                SDWebImageLoader(url: url, contentMode: contentMode, targetSize: targetSize)
            }
            .clipped()
    }
}

fileprivate struct SDWebImageLoader: View {
    let url: URL
    var contentMode: ContentMode = .fill
    var targetSize: CGSize
    
    var body: some View {
        WebImage(url: url, context: [.imageTransformer: ResizingImageTransformer(targetSize: targetSize)]) { image in
            image
        } placeholder: {
            ProgressView()
                .scaleEffect(1.5)
        }
        .onSuccess { image, data, cacheType in
            switch cacheType {
            case .none:
                print("DEBUG: Image downloaded from network")
            case .disk:
                print("DEBUG: Image loaded from disk cache")
            case .memory:
                print("DEBUG: Image loaded from memory cache")
            case .all:
                print("DEBUG: all")
            @unknown default:
                print("DEBUG: Unknown cache type")
            }
        }
        .onFailure { error in
            print("DEBUG: Failed to load image: \(String(describing: error))")
        }
        .resizable()
        .aspectRatio(contentMode: contentMode)
        .transition(.fade(duration: 0.5))
    }
}

final class ImagePrefetcher {
    static let instance = ImagePrefetcher()
    private let prefetcher = SDWebImagePrefetcher()
    
    private init() {}
    
    func startPrefetching(urls: [URL]) {
        prefetcher.prefetchURLs(urls)
    }
    
    func stopPrefetching() {
        prefetcher.cancelPrefetching()
    }
}

final class ResizingImageTransformer: NSObject, SDImageTransformer {
    let targetSize: CGSize
    
    init(targetSize: CGSize) {
        self.targetSize = targetSize
    }
    
    func transformedImage(with image: UIImage, forKey key: String) -> UIImage? {
        return image.resize(Int(targetSize.width), Int(targetSize.height))
    }
    
    var transformerKey: String {
        return "ResizingImageTransformer(\(targetSize.width)x\(targetSize.height))"
    }
}

//struct ImageLoader: View {
//    let url: URL
//    var contentMode: ContentMode = .fit
//    
//    var body: some View {
//       Rectangle()
//            .opacity(0)
//            .overlay {
//                SDWebImageLoader(url: url, contentMode: contentMode)
//            }
//            .clipped()
//    }
//}
//
//fileprivate struct SDWebImageLoader: View {
//    let url: URL
//    var contentMode: ContentMode = .fit
//
//    var body: some View {
//        WebImage(url: url) { image in
//            image
//        } placeholder: {
//            ProgressView()
//                .scaleEffect(1.5)
//        }
//        .onSuccess { image, data, cacheType in
//            switch cacheType {
//            case .none:
//                print("Image downloaded from network")
//            case .disk:
//                print("Image loaded from disk cache")
//            case .memory:
//                print("Image loaded from memory cache")
//            case .all:
//                print("all")
//            @unknown default:
//                print("Unknown cache type")
//            }
//        }
//        .onFailure { error in
//            print("Failed to load image: \(String(describing: error))")
//        }
//        .resizable()
//        .aspectRatio(contentMode: contentMode)
//        .transition(.fade(duration: 0.5))
//    }
//}
