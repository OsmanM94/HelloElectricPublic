//
//  ImageCounterView.swift
//  Clin
//
//  Created by asia on 22/08/2024.
//

import SwiftUI

struct ImageCounterView: View {
    let count: Int
    
    var body: some View {
        Image(systemName: count <= 0 ? "photo.badge.plus": "photo")
            .foregroundStyle(.gray)
            .font(.system(size: 24))
            .symbolRenderingMode(.multicolor)
            .overlay(alignment: .topTrailing) {
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 12).bold())
                        .foregroundStyle(.white)
                        .padding(5)
                        .background(Color(.red))
                        .clipShape(Circle())
                        .offset(x: 2, y: -6)
                }
            }
    }
}

#Preview {
    ImageCounterView(count: 10)
}
