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
        format.scale = 2.5
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

/// Date formatter
public extension String {
    // Converts the ISO 8601 date string to a Date object
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.date(from: self)
    }
    
    // Converts the ISO 8601 date string to a formatted date string
    func toFormattedDateString() -> String {
        guard let date = self.toDate() else {
            return self
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
}

/// Safely creates a `URL` instance from a `String`.
public extension URL {
    /// - Parameter urlString: The `String` representing the URL.
    /// - Returns: A `URL` instance if the string is valid, otherwise `nil`.
    static func from(_ urlString: String?) -> URL? {
        guard let urlString = urlString else { return nil }
        return URL(string: urlString)
    }
}

/// Set time elapse eg. 3 days ago 
public extension Date {
    func timeElapsedString() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

/// This computed property takes the current string, filters out non-numeric characters, and formats it as a UK phone number (assuming the format is 07700 900 000).
extension String {
    var formattedPhoneNumber: String {
        let cleaned = self.filter { $0.isNumber }
        guard cleaned.count >= 11 else { return cleaned }
        let firstPart = cleaned.prefix(5)
        let secondPart = cleaned.dropFirst(5).prefix(3)
        let thirdPart = cleaned.dropFirst(8)
        return "\(firstPart) \(secondPart) \(thirdPart)"
    }
    
    var isValidPhoneNumber: Bool {
        let cleaned = self.filter { $0.isNumber }
        return cleaned.count == 11
    }
}

// Extension to convert API Key to Base64
extension String {
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
