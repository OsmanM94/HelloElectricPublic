//
//  EVRowView.swift
//  Clin
//
//  Created by asia on 13/09/2024.
//

import SwiftUI

struct EVRowView: View {
    let ev: EVDatabase
    
    var body: some View {
        HStack {
            if let imageURL = ev.image1?.first {
                ImageLoader(url: imageURL, contentMode: .fill, targetSize: CGSize(width: 50, height: 50))
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
            }
            
            VStack(alignment: .leading) {
                Text(ev.carName ?? "Unknown Model")
                    .font(.headline)
                Text(ev.availableSince ?? "Unknown Year")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    EVRowView(ev: EVDatabase.sampleData)
}
