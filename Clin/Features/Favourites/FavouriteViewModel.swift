//
//  FavouriteViewModel.swift
//  Clin
//
//  Created by asia on 25/07/2024.
//

import Foundation
import Factory

@Observable
final class FavouriteViewModel {
    enum ViewState: Equatable {
        case empty
        case loaded
        case error(String)
    }
    
    enum FavouriteViewStateMessages: String, Error {
        case generalError = "An error occurred. Please try again."
        case noAuthUserFound = "No authenticated user found."
        
        var message: String {
            return self.rawValue
        }
    }
    
    private(set) var viewState: ViewState = .empty
    private(set) var favoriteListings: [Favourite] = []
    private(set) var isFavourite: Bool = false
    
    @ObservationIgnored
    @Injected(\.favouriteService) private var favouriteService
    @ObservationIgnored
    @Injected(\.supabaseService) private var supabaseService
    
    init() {
        Task {
            await fetchUserFavorites()
            print("DEBUG: Initialising user favourites...")
        }
    }
    
    @MainActor
    func addToFavorites(listing: Listing) async  {
        guard let user = try? await supabaseService.client.auth.session.user else {
            print("DEBUG: No authenticated user found, can't add to favourites.")
            return
        }
        guard let id = listing.id else {
            print("DEBUG: Listing ID is missing for favourites.")
            return
        }
        
        let favourite = Favourite(
                    userID: user.id,
                    listingID: id,
                    imagesURL: listing.imagesURL,
                    thumbnailsURL: listing.thumbnailsURL,
                    make: listing.make,
                    model: listing.model,
                    condition: listing.condition,
                    mileage: listing.mileage,
                    price: listing.price
                )
        do {
            try await favouriteService.addToFavorites(favourite)
            favoriteListings.append(favourite)
            
            print("DEBUG: Listing added to favourites successfully.")
        } catch {
            print("DEBUG: Error creating listing: \(error)")
            viewState = .error(FavouriteViewStateMessages.generalError.message)
        }
    }
    
    @MainActor
    func removeFromFavorites(favourite: Favourite) async  {
        guard let user = try? await supabaseService.client.auth.session.user else {
            print("DEBUG: No authenticated user found for favourites.")
            return
        }
        do {
            try await favouriteService.removeFromFavorites(favourite, for: user.id)
            
            if let index = favoriteListings.firstIndex(where: { $0.id == favourite.id }) {
                favoriteListings.remove(at: index)
            }
            print("DEBUG: Listing removed from favorites successfully.")
        } catch {
            print("DEBUG: Error removing listing from favorites: \(error)")
            viewState = .error(FavouriteViewStateMessages.generalError.message)
        }
    }
    
    @MainActor
    func fetchUserFavorites() async  {
        guard let user = try? await supabaseService.client.auth.session.user else {
            print("DEBUG: No authenticated user found for favourites, can't fetch.")
            return
        }
        do {
            self.favoriteListings = try await favouriteService.loadUserFavourites(userID: user.id)
            updateViewState()
        } catch {
            print("DEBUG: Error fetching user listings: \(error)")
            viewState = .error(FavouriteViewStateMessages.generalError.message)
        }
    }
    
    func isFavourite(listing: Listing) -> Bool {
        return favoriteListings.contains { $0.listingID == listing.id }
    }
    
    @MainActor
    func toggleFavourite(for listing: Listing) async throws {
        if let favourite = favoriteListings.first(where: { $0.listingID == listing.id }) {
             await removeFromFavorites(favourite: favourite)
        } else {
             await addToFavorites(listing: listing)
        }
    }
    
    @MainActor
    private func updateViewState() {
        viewState = favoriteListings.isEmpty ? .empty : .loaded
    }
}

