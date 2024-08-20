//
//  ListingViewPlaceholders.swift
//  Clin
//
//  Created by asia on 11/08/2024.
//

import SwiftUI

struct ListingsPlaceholder: View {
    @State private var isLoading: Bool = true
    let retryAction: () async -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            List(0 ..< 6) { item in
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
                }
                .padding(.leading, 5)
                .padding(.vertical, 10)
            }
            .listStyle(.plain)
            .shimmer(when: $isLoading)
            .refreshable {
                await retryAction()
            }
        }
        .onDisappear {
            isLoading = false
        }
    }
}

#Preview {
    NavigationStack {
        ListingsPlaceholder(retryAction: {})
    }
}


struct SearchBarPlaceholder: View {
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
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding([.top, .bottom, .horizontal])
    }
}
