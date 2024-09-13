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
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } placeholder: {
                    ProgressView()
                        .frame(width: 50, height: 50)
                }
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
