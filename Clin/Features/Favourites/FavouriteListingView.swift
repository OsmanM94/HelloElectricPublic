//
//  FavouriteListingView.swift
//  Clin
//
//  Created by asia on 25/07/2024.
//

import SwiftUI

struct FavouriteListingView: View {
    
    @EnvironmentObject private var viewModel: FavouriteViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.viewState {
                case .loaded:
                    FavouriteListingSubview()
                      
                case .empty:
                    EmptyContentView(message: "You haven't saved any listings yet.", systemImage: "heart.slash.fill")
                    
                case .error(let message):
                    ErrorView(message: message, retryAction: {
                        Task {
                            await viewModel.fetchUserFavorites()
                        }
                    })
                }
            }
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await viewModel.fetchUserFavorites()
            print("DEBUG: Fetching user favourites via task modifier...")
        }
    }
}

#Preview("Empty View") {
    FavouriteListingView()
        .environmentObject(FavouriteViewModel(favouriteService: MockFavouriteService()))
}

fileprivate struct FavouriteListingSubview: View {
    @EnvironmentObject private var viewModel: FavouriteViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.favoriteListings, id: \.id) { favourite in
                FavouriteCell(favourite: favourite)
                    .swipeActions(allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            Task {
                              await viewModel.removeFromFavorites(favourite: favourite)
                              await viewModel.fetchUserFavorites()
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
        .refreshable { await viewModel.fetchUserFavorites() }
    }
}




