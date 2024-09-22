//
//  UserListingsPublic.swift
//  Clin
//
//  Created by asia on 21/09/2024.
//

import SwiftUI

struct PublicUserListingsView: View {
    var viewModel: PublicUserListingsViewModel
    
    var body: some View {
        VStack {
            switch viewModel.viewState {
            case .empty:
                ErrorView(
                    message: "No listings found",
                    retryAction: { await viewModel.loadListings() },
                    systemImage: "tray.fill")
                
            case .loading:
                CustomProgressView(message: "Checking...")
                
            case .success:
                mainContent
                
            case .error(let message):
                ErrorView(
                    message: message,
                    retryAction: { await viewModel.loadListings() },
                    systemImage: "xmark.circle.fill")
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
        .navigationTitle("Seller listings")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.listings.isEmpty {
                await viewModel.loadListings()
            }
        }

    }
    
    private var mainContent: some View {
        List {
            ForEach(viewModel.listings, id: \.id) { listing in
                NavigationLink(destination: DetailView(item: listing, showFavourite: false)) {
                    ListingRowView(listing: listing, showFavourite: false)
                        .id(listing.id)
                }
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    PublicUserListingsView(viewModel: PublicUserListingsViewModel(sellerID: UUID()))
}
