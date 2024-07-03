//
//  UserListingView.swift
//  Clin
//
//  Created by asia on 25/06/2024.
//

import SwiftUI

struct UserListingView: View {
    
    @State private var viewModel = UserListingsViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                VStack {
                    switch viewModel.state {
                    case .idle:
                        ProgressView()
                            .scaleEffect(1.5)
                    case .loaded:
                        List {
                            ForEach(viewModel.userActiveListings, id: \.id) { listing in
                                Text(listing.title)
                            }
                            .listRowSeparator(.hidden, edges: .all)
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("Active listings")
        }
        .task {
            await viewModel.fetchUserListings()
        }
    }
}

#Preview {
    UserListingView()
}
