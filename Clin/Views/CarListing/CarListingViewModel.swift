//
//  CarListingViewModel.swift
//  Clin
//
//  Created by asia on 23/06/2024.
//

import Foundation


@Observable
final class CarListingViewModel {
    var listings: [CarListing] = []
    var state: ViewState = .idle
    var title: String = ""
   
    private let carListingService = CarListingService()
    private let supabase = SupabaseService.shared.client
    
    @MainActor
    func fetchListings() async {
        state = .loading
        
        do {
            listings = try await carListingService.fetchListings()
            state = .loaded
        } catch {
            state = .error("Error fetching listings: \(error)")
        }
    }
    
    @MainActor
    func createListing() async {
        state = .loading
        
        do {
            guard let user = try? await supabase.auth.session.user else {
                print("No authenticated user found")
                state = .error("No authenticated user found.")
                return
            }
            try await carListingService.createListing(title: title, userID: user.id)
            state = .loaded
            print("Listing created succcesfully.")
        } catch {
            state = .error("Error creating listing: \(error)")
        }
    }
    
    @MainActor
    func updateListing(_ listing: CarListing, title: String) async {
        state = .loading
        
        do {
            try await carListingService.updateListing(listing, title: title)
            state = .loaded
            print("Listing updated succesfully.")
            
        } catch {
            state = .error("Error updating listing: \(error)")
        }
    }
    
    func deleteListing(at id: Int) async {
        state = .loading
        
        do {
            try await carListingService.deleteListing(at: id)
            state = .loaded
            print("Listing deleted succesfully")
            
        } catch {
            state = .error("Error deleting listing: \(error)")
        }
    }
}
