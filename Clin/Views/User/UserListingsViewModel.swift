//
//  UserListings.swift
//  Clin
//
//  Created by asia on 25/06/2024.
//

import Foundation


@Observable
final class UserListingsViewModel {
    var userActiveListings: [CarListing] = []
    var state: ViewState = .idle
    
    private let carListingService = CarListingService.shared
    private let supabase = SupabaseService.shared.client
    private var userID: UUID?
    
    @MainActor
    func fetchUserListings() async {
        state = .idle
        do {
            guard let user = try? await supabase.auth.session.user else {
                print("No authenticated user found")
                return
            }
            
            userID = user.id
            userActiveListings = try await carListingService.fetchUserListings(userID: user.id)
            
            state = .loaded
        } catch {
            print("Error fetching user listings.")
        }
    }
    
    @MainActor
    func updateUserListing(_ listing: CarListing, title: String) async {
        do {
            try await carListingService.updateListing(listing, title: title)
            state = .loaded
            
            print("Listing updated succesfully.")
        } catch {
            print("Error updating listing: \(error)")
        }
    }
    
    @MainActor
    func deleteUserListing(at id: Int) async {
        do {
            try await carListingService.deleteListing(at: id)
            state = .loaded
            print("Listing deleted succesfully")
            
        } catch {
            print("Error deleting listing: \(error)")
        }
    }
}
