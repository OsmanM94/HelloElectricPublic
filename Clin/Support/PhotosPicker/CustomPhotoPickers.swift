//
//  PhotosPickerView.swift
//  Clin
//
//  Created by asia on 25/07/2024.
//

import SwiftUI
import PhotosUI

struct MultiplePhotosPicker: View {
    @Binding var selections: [PhotosPickerItem]
    let maxSelectionCount: Int?
    let selectionBehavior: PhotosPickerSelectionBehavior?
    let icon: String
    let size: CGFloat
    let colour: Color
    var onSelect: ([PhotosPickerItem]) -> Void
    
    var body: some View {
        PhotosPicker(selection: $selections,maxSelectionCount: maxSelectionCount ,matching: .any(of: [.images, .screenshots]), photoLibrary: .shared()) {
            Image(systemName: icon)
                .symbolRenderingMode(.multicolor)
                .font(.system(size: size))
                .foregroundStyle(colour)
        }
        .onChange(of: selections) { _, newItems in
            onSelect(newItems)
        }
    }
}

struct SinglePhotoPicker<Content: View>: View {
    @Binding var selection: PhotosPickerItem?
    let photoLibrary: PHPhotoLibrary
    let content: () -> Content
    var onSelect: (PhotosPickerItem?) -> Void
    
    var body: some View {
        PhotosPicker(selection: $selection, matching:  .any(of: [.images, .screenshots]), photoLibrary: photoLibrary) {
            content()
        }
        .onChange(of: selection) { _, newItems in
            onSelect(newItems)
        }
    }
}

