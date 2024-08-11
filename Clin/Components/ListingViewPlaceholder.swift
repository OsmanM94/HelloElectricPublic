//
//  ListingViewPlaceholders.swift
//  Clin
//
//  Created by asia on 11/08/2024.
//

import SwiftUI

struct ListingViewPlaceholder: View {
    @State private var textPlaceholder: String = ""
    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(0..<10) { _ in
                    HStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 60, height: 60)
                        
                        VStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 20)
                            
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 20)
                                .padding(.top, 5)
                        }
                        .padding(.leading, 5)
                    }
                    .padding(.vertical, 10)
                }
            }
            .navigationTitle("Listings")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $textPlaceholder)
            .listStyle(.plain)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        ListingViewPlaceholder()
    }
}
