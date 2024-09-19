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
    // MARK: - Enum
    enum ViewState: Equatable {
        case empty
        case loading
        case loaded
        case error(String)
    }
    
    // MARK: - Observable properties
    private(set) var viewState: ViewState = .loading
    private(set) var favoriteListings: [Favourite] = []
    private(set) var isFavourite: Bool = false
    
    // MARK: - Dependencies
    @ObservationIgnored @Injected(\.favouriteService) private var favouriteService
    @ObservationIgnored @Injected(\.supabaseService) private var supabaseService
    
    init() {
        Task {
            await loadUserFavourites()
//            print("DEBUG: Initialising user favourites...")
        }
    }
    
    // MARK: - Main actor functions
    
    @MainActor
    func addToFavorites(listing: Listing) async  {
        guard let user = try? await supabaseService.client.auth.session.user else { return }
        
        guard let id = listing.id else {
            print("DEBUG: Listing ID is missing for favourites.")
            return
        }
        
        let favourite = Favourite(
            createdAt: listing.createdAt,
            imagesURL: listing.imagesURL,
            thumbnailsURL: listing.thumbnailsURL,
            make: listing.make,
            model: listing.model,
            bodyType: listing.bodyType,
            condition: listing.condition,
            mileage: listing.mileage,
            location: listing.location,
            yearOfManufacture: listing.yearOfManufacture,
            price: listing.price,
            phoneNumber: listing.phoneNumber,
            textDescription: listing.textDescription,
            range: listing.range,
            colour: listing.colour,
            publicChargingTime: listing.publicChargingTime,
            homeChargingTime: listing.homeChargingTime,
            batteryCapacity: listing.batteryCapacity,
            powerBhp: listing.powerBhp,
            regenBraking: listing.regenBraking,
            warranty: listing.warranty,
            serviceHistory: listing.serviceHistory,
            numberOfOwners: listing.numberOfOwners,
            userID: user.id,
            listingID: id,
            isPromoted: listing.isPromoted
        )
        do {
            try await favouriteService.addToFavorites(favourite)
            favoriteListings.append(favourite)
            
            print("DEBUG: Listing added to favourites successfully.")
        } catch {
            print("DEBUG: Error creating listing: \(error)")
            viewState = .error(AppError.ErrorType.generalError.message)
        }
    }
    
    @MainActor
    func removeFromFavorites(favourite: Favourite) async  {
        guard let user = try? await supabaseService.client.auth.session.user else { return }
        
        do {
            try await favouriteService.removeFromFavorites(favourite, for: user.id)
            
            if let index = favoriteListings.firstIndex(where: { $0.id == favourite.id }) {
                favoriteListings.remove(at: index)
            }
            print("DEBUG: Listing removed from favorites successfully.")
        } catch {
            self.viewState = .error(AppError.ErrorType.generalError.message)
        }
    }
    
    @MainActor
    func loadUserFavourites() async  {
        guard let user = try? await supabaseService.client.auth.session.user else { return }
        
        do {
            let listings = try await favouriteService.loadUserFavourites(userID: user.id)
            self.favoriteListings = listings
            
            self.viewState = listings.isEmpty ? .empty : .loaded
        } catch {
            viewState = .error(AppError.ErrorType.generalError.message)
        }
    }
    
    @MainActor
    func toggleFavourite(for listing: Listing) async {
        if let favourite = favoriteListings.first(where: { $0.listingID == listing.id }) {
             await removeFromFavorites(favourite: favourite)
        } else {
             await addToFavorites(listing: listing)
        }
    }
    
    func isFavourite(listing: Listing) -> Bool {
        return favoriteListings.contains { $0.listingID == listing.id }
    }
}

