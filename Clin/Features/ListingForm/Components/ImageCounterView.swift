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
        Image(systemName: "photo")
            .foregroundStyle(.gray)
            .font(.system(size: 24))
            .overlay(alignment: .topTrailing) {
                Text("\(count)")
                    .font(.system(size: 13).bold())
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(Color(.red))
                    .clipShape(Circle())
                    .offset(x: 4, y: -8)
            }
    }
}

#Preview {
    ImageCounterView(count: 1)
}
