//
//  ListingViewPlaceholders.swift
//  Clin
//
//  Created by asia on 11/08/2024.
//

import SwiftUI

struct ListingViewPlaceholder: View {
    @State var showTextField: Bool
    @State private var isLoading: Bool = true
    let retryAction: () async -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if showTextField {
                SearchableView(search: .constant(""), disableTextInput: true)
                    .padding([.top, .bottom])
            }
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
            .navigationTitle("Listings")
            .navigationBarTitleDisplayMode(.inline)
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
        ListingViewPlaceholder(showTextField: true, retryAction: {})
    }
}

