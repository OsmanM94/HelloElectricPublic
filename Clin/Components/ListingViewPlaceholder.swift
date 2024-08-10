//
//  ListingViewPlaceholders.swift
//  Clin
//
//  Created by asia on 11/08/2024.
//

import SwiftUI

struct ListingViewPlaceholder: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("Loading...")
                .font(.title)
                .redacted(reason: .placeholder)
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
            .listStyle(.plain)
            .redacted(reason: .placeholder)
        }
        .padding()
    }
}

#Preview {
    ListingViewPlaceholder()
}
