//
//  UserListings.swift
//  Clin
//
//  Created by asia on 25/06/2024.
//

import Foundation


@Observable
final class UserListingsViewModel {
    enum UserListingsViewState {
        case loading
        case loaded
        case error(String)
    }
    var userActiveListings: [CarListing] = []
    var viewState: UserListingsViewState = .loading
    
    private let carListingService = DatabaseService.shared
    private let supabase = SupabaseService.shared.client
    private var userID: UUID?
    
    @MainActor
    func fetchUserListings() async {
        viewState = .loading
        do {
            guard let user = try? await supabase.auth.session.user else {
                print("No authenticated user found")
                return
            }
            
            userID = user.id
            userActiveListings = try await carListingService.fetchUserListings(userID: user.id)
            
            viewState = .loaded
        } catch {
            viewState = .error("Error retrieving listings.")
        }
    }
    
    @MainActor
    func updateUserListing(_ listing: CarListing, make: String) async {
        do {
            try await carListingService.updateListing(listing, make: make)
            viewState = .loaded
            
            print("Listing updated succesfully.")
        } catch {
            viewState = .error("Error updating the listing, please try again.")
        }
    }
    
    @MainActor
    func deleteUserListing(at id: Int) async {
        do {
            try await carListingService.deleteListing(at: id)
            viewState = .loaded
            print("Listing deleted succesfully")
            
        } catch {
            viewState = .error("Error deleting the listing, please try again.")
        }
    }
}
