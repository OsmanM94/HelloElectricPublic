//
//  FavouriteListingView.swift
//  Clin
//
//  Created by asia on 25/07/2024.
//

import SwiftUI

struct FavouriteListingView: View {
    @EnvironmentObject private var favouriteViewModel: FavouriteViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                switch favouriteViewModel.viewState {
                case .loaded:
                    LoadedFavouriteView()
                case .empty:
                    EmptyContentView(message: "No listings saved", systemImage: "heart.slash.fill")
                }
            }
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview("Empty View") {
    FavouriteListingView()
        .environmentObject(FavouriteViewModel())
}

private struct LoadedFavouriteView: View {
    @EnvironmentObject private var favouriteViewModel: FavouriteViewModel
    
    var body: some View {
        List {
            ForEach(favouriteViewModel.favourite, id: \.listing.id) { listing in
                FavouriteCell(favouriteListing: listing)
                    .swipeActions(allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            withAnimation {
                                favouriteViewModel.removeFromFavorites(listing: listing.listing)
                            }
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
            }
            .alignmentGuide(.listRowSeparatorLeading) { _ in
                0
            }
        }
        .listStyle(.plain)
        .padding(.top)
        .refreshable {}
    }
}
