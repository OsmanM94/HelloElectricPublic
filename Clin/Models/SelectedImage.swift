//
//  AvatarImage.swift
//  Clin
//
//  Created by asia on 26/06/2024.
//

import Foundation
import SwiftUI

struct SelectedImage: Transferable, Equatable, Hashable, Identifiable {
    let id = UUID()
    let image: Image
    let data: Data
   
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let image = SelectedImage(data: data) else {
                throw TransferError.importFailed
            }
            
            return image
        }
    }
    static func == (lhs: SelectedImage, rhs: SelectedImage) -> Bool {
        lhs.data == rhs.data
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(data)
    }
}

extension SelectedImage {
    init?(data: Data) {
        guard let uiImage = UIImage(data: data) else {
            return nil
        }
        
        let image = Image(uiImage: uiImage)
        self.init(image: image, data: data)
    }
}

enum TransferError: Error {
    case importFailed
}