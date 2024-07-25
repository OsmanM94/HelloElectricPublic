//
//  FavouriteViewModel.swift
//  Clin
//
//  Created by asia on 25/07/2024.
//

import Foundation


final class FavouriteViewModel: ObservableObject {
    enum FavouriteViewState {
        case loaded
        case empty
    }
    
    @Published var viewState: FavouriteViewState = .empty
    @Published var favourite = [FavouriteListing]()
    
    func addToFavorites(listing: Listing) {
        if let index = favourite.firstIndex(where: { $0.listing.id == listing.id }) {
            favourite.remove(at: index)
        } else {
            let favoriteProduct = FavouriteListing(listing: listing)
            favourite.append(favoriteProduct)
        }
        updateViewState()
    }
    
    func removeFromFavorites(listing: Listing) {
        if let index = favourite.firstIndex(where: { $0.listing.id == listing.id }) {
            favourite.remove(at: index)
        }
        updateViewState()
    }
    
    func isFavorite(listing: Listing) -> Bool {
        return favourite.contains(where: { $0.listing.id == listing.id })
    }
    
    private func updateViewState() {
        if favourite.isEmpty {
            viewState = .empty
        } else {
            viewState = .loaded
        }
    }
}
