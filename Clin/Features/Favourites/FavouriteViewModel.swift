//
//  FavouriteViewModel.swift
//  Clin
//
//  Created by asia on 25/07/2024.
//

import Foundation


final class FavouriteViewModel: ObservableObject {
    enum ViewState {
        case loaded
        case empty
    }
    
    @Published var viewState: ViewState = .empty
    @Published var favourite = [Favourite]()
    
    func addToFavorites(listing: Listing) {
        if let index = favourite.firstIndex(where: { $0.listing.id == listing.id }) {
            favourite.remove(at: index)
        } else {
            let favoriteProduct = Favourite(listing: listing)
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
