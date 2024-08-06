//
//  Extensions.swift
//  Clin
//
//  Created by asia on 07/08/2024.
//

import Foundation
import SwiftUI
import AVFoundation


/// Resize image while keeping the aspect ratio. Original image is not modified.
public extension UIImage {
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


/// Purpose: The onUpdate extension on Binding is used to run a specified closure whenever the binding value changes.
extension Binding {
    func onUpdate(_ closure: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { newValue in
                wrappedValue = newValue
                closure(newValue)
            }
        )
    }
}
