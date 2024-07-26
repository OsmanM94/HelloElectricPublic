//
//  PhotosPickerView.swift
//  Clin
//
//  Created by asia on 25/07/2024.
//

import SwiftUI
import PhotosUI


struct PhotosPickerView: View {
    @Binding var selections: [PhotosPickerItem]
    let maxSelectionCount: Int
    let selectionBehavior: PhotosPickerSelectionBehavior
    let icon: String
    let size: CGFloat
    let colour: Color
    var onSelect: ([PhotosPickerItem]) -> Void
    
    var body: some View {
        PhotosPicker(selection: $selections, maxSelectionCount: maxSelectionCount, selectionBehavior: selectionBehavior, matching: .any(of: [.images, .screenshots]), photoLibrary: .shared()) {
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

