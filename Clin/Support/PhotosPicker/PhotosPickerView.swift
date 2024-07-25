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
       var maxSelectionCount: Int
       var selectionBehavior: PhotosPickerSelectionBehavior
       var onSelect: ([PhotosPickerItem]) -> Void

       var body: some View {
           PhotosPicker(selection: $selections, maxSelectionCount: maxSelectionCount, selectionBehavior: selectionBehavior, matching: .any(of: [.images, .screenshots]), photoLibrary: .shared()) {
               Image(systemName: "camera")
                   .symbolRenderingMode(.multicolor)
                   .font(.system(size: 20))
           }
           .onChange(of: selections) { _, newItems in
               onSelect(newItems)
           }
       }
}

