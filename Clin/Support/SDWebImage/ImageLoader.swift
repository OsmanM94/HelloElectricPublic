//
//  ImageLoader.swift
//  Clin
//
//  Created by asia on 30/06/2024.
//

import SwiftUI
import SDWebImageSwiftUI
import AVFoundation

struct ImageLoader: View {
    let url: URL
    var contentMode: ContentMode = .fit
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
    var contentMode: ContentMode = .fit
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

public extension UIImage {
    /// Resize image while keeping the aspect ratio. Original image is not modified.
    /// - Parameters:
    ///   - width: A new width in pixels.
    ///   - height: A new height in pixels.
    /// - Returns: Resized image.
    func resize(_ width: Int, _ height: Int) -> UIImage? {
        // Keep aspect ratio
        let maxSize = CGSize(width: width, height: height)

        let availableRect = AVFoundation.AVMakeRect(
            aspectRatio: self.size,
            insideRect: .init(origin: .zero, size: maxSize)
        )
        let targetSize = availableRect.size

        // Set scale of renderer so that 1pt == 1px
        let format = UIGraphicsImageRendererFormat()
        format.scale = 3.0
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

        // Resize the image
        let resized = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return resized
    }
    
    func heicData(compressionQuality: CGFloat = 1.0) -> Data? {
        let options: NSDictionary = [
            kCGImageDestinationLossyCompressionQuality: compressionQuality
        ]
        let data = NSMutableData()
        guard let imageDestination = CGImageDestinationCreateWithData(data as CFMutableData, AVFileType.heic as CFString, 1, nil) else {
            return nil
        }
        CGImageDestinationAddImage(imageDestination, self.cgImage!, options)
        CGImageDestinationFinalize(imageDestination)
        return data as Data
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
