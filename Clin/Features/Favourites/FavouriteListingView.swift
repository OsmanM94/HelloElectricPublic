//
//  FavouriteListingView.swift
//  Clin
//
//  Created by asia on 25/07/2024.
//

import SwiftUI

struct FavouriteListingView: View {
    @Environment(FavouriteViewModel.self) private var viewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.viewState {
                case .empty:
                    ErrorView(
                        message: "Empty",
                        refreshMessage: "Refresh",
                        retryAction: { await viewModel.loadUserFavourites() },
                        systemImage: "heart.slash.fill")
                    
                case .loading:
                    CustomProgressView(message: "Loading...")
                    
                case .loaded:
                    FavouriteListingSubview()
                    
                case .error(let message):
                    ErrorView(
                        message: message,
                        refreshMessage: "Try again",
                        retryAction: { await viewModel.loadUserFavourites() },
                        systemImage: "xmark.circle.fill")
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await viewModel.loadUserFavourites()
        }
    }
}

#Preview("Empty View") {
    let _ = PreviewsProvider.shared.container.favouriteService.register { MockFavouriteService() }
    FavouriteListingView()
        .environment(FavouriteViewModel())
}

fileprivate struct FavouriteListingSubview: View {
    @Environment(FavouriteViewModel.self) private var viewModel
    
    var body: some View {
        List {
            ForEach(viewModel.favoriteListings, id: \.listingID) { favourite in
                NavigationLink(destination: DetailView(item: favourite)) {
                    FavouriteRowView(favourite: favourite, action: {
                        Task {
                            await viewModel.removeFromFavorites(favourite: favourite)
                            await viewModel.loadUserFavourites()
                        }
                    })
                    .id(favourite.id)
                }
            }
            .listRowSeparator(.hidden, edges: .all)
        }
        .listStyle(.plain)
        .padding(.top)
        .refreshable { await viewModel.loadUserFavourites() }
    }
}




