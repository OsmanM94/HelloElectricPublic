//
//  SearchableView.swift
//  Clin
//
//  Created by asia on 13/08/2024.
//

import SwiftUI

struct SearchableView: View {
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.gray)
            
            Text("Search")
                .foregroundStyle(.gray)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
        .background(Color(.systemGray5).opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        SearchableView()
            .previewLayout(.sizeThatFits)
    }
}
