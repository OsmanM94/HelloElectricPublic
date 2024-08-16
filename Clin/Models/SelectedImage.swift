//
//  AvatarImage.swift
//  Clin
//
//  Created by asia on 26/06/2024.
//

import SwiftUI
import PhotosUI

struct SelectedImage: Transferable, Equatable, Hashable, Identifiable {
    let id: String
    let image: Image
    let data: Data
    let photosPickerItem: PhotosPickerItem?
   
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let image = SelectedImage(data: data, photosPickerItem: nil) else {
                throw TransferError.importFailed
            }
            
            return image
        }
    }
    
    static func == (lhs: SelectedImage, rhs: SelectedImage) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension SelectedImage {
    init?(data: Data, id: String? = nil, photosPickerItem: PhotosPickerItem?) {
        guard let uiImage = UIImage(data: data) else {
            return nil
        }
        
        let image = Image(uiImage: uiImage)
        self.init(id: id ?? UUID().uuidString, image: image, data: data, photosPickerItem: photosPickerItem)
    }
}

enum TransferError: Error {
    case importFailed
}


