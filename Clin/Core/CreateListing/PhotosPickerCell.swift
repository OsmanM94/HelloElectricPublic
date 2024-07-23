//
//  PhotosPickerCell.swift
//  Clin
//
//  Created by asia on 23/07/2024.
//

import SwiftUI

struct PhotosPickerCell: View {
    let action: () -> Void
    var image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: 100, height: 100)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(alignment: .topTrailing) {
                Button {
                    action()
                } label: {
                    ZStack {
                        Rectangle()
                            .foregroundStyle(.red.gradient)
                            .frame(width: 20, height: 20)
                            .clipShape(Circle())
                        Image(systemName: "xmark")
                            .foregroundStyle(.white)
                            .imageScale(.small)
                    }
                }
                .offset(x: 5, y: -6)
            }
    }
}

#Preview {
    PhotosPickerCell(action: {}, image: UIImage(named: "ev")!)
}
