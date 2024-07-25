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
                    switch viewModel.viewState {
                    case .empty:
                        EmptyContentView(message: "No active listings found", systemImage: "tray.fill")
                    case .loaded:
                        List {
                            ForEach(viewModel.userActiveListings, id: \.id) { listing in
                                ListingCell(listing: listing)
                            }
                            .listRowSeparator(.hidden, edges: .all)
                        }
                        .listStyle(.plain)
                     
                    case .error(let message):
                        ErrorView(message: message, retryAction: {
                            Task { await viewModel.fetchUserListings() }
                        })
                    }
                }
            }
            .navigationTitle("Active listings")
        }
        .task { await viewModel.fetchUserListings() }
    }
}

#Preview {
    UserListingView()
}
