//
//  Extensions.swift
//  Clin
//
//  Created by asia on 07/08/2024.
//
import SwiftUI
import AVFoundation


/// Resize image while keeping the aspect ratio. Original image is not modified.
public extension UIImage {
    func resize(_ width: Int, _ height: Int) -> UIImage? {
        // Return nil if the image has no valid size
        guard self.size.width > 0, self.size.height > 0 else {
            return nil
        }
        // Keep aspect ratio
        let maxSize = CGSize(width: width, height: height)

        let availableRect = AVFoundation.AVMakeRect(
            aspectRatio: self.size,
            insideRect: .init(origin: .zero, size: maxSize)
        )
        let targetSize = availableRect.size

        // Set scale of renderer so that 1pt == 1px
        let format = UIGraphicsImageRendererFormat()
//        format.scale = UIScreen.main.scale
        format.scale = 3.0
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

        // Resize the image
        let resized = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return resized
    }
        
    func heicData(compressionQuality: CGFloat = 1.0) -> Data? {
        let destinationData = NSMutableData()
        
        guard let cgImage = self.cgImage,
              let destination = CGImageDestinationCreateWithData(destinationData, AVFileType.heic as CFString, 1, nil) else { return nil }
        
        let options: CFDictionary = [kCGImageDestinationLossyCompressionQuality: compressionQuality] as CFDictionary
        CGImageDestinationAddImage(destination, cgImage, options)
        CGImageDestinationFinalize(destination)
        
        return destinationData as Data
    }
}

/// Shimmer modifier
public extension View {
    @ViewBuilder
    func shimmer(when isLoading: Binding<Bool>) -> some View {
        if isLoading.wrappedValue {
            self.modifier(Shimmer())
                .redacted(reason: isLoading.wrappedValue ? .placeholder : [])
        } else {
            self
        }
    }
}

/// This modifier shows an alert when the Sensitive Content Analysis is turned off.
public extension View {
    func sensitiveContentAnalysisCheck() -> some View {
        self.modifier(SensitiveContentAnalysisModifier())
    }
}
