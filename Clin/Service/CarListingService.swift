//
//  CarListingService.swift
//  Clin
//
//  Created by asia on 24/06/2024.
//

import Foundation


struct CarListingService {
    static let shared = CarListingService()
    
    private let supabase = SupabaseService.shared.client
    
    private init() {}
    
    func fetchListings() async throws -> [CarListing] {
        do {
            let listings: [CarListing] = try await supabase
                .from("CarListing")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value
            return listings
        } catch {
            print("Error fetching listings: \(error)")
            throw error
        }
    }
    
    func fetchUserListings(userID: UUID) async throws -> [CarListing] {
        do {
            let listings: [CarListing] = try await supabase
                .from("CarListing")
                .select()
                .eq("user_id", value: userID)
                .order("created_at", ascending: false)
                .execute()
                .value
            return listings
        } catch {
            print("Error fetching user listings: \(error)")
            throw error
        }
    }
    
    func createListing(title: String, userID: UUID) async throws {
        do {
            let listing = CarListing(createdAt: Date(), title: title, userID: userID)
            try await supabase
                .from("CarListing")
                .insert(listing)
                .execute()
            print("Listing created successfully.")
        } catch {
            print("Error creating listing: \(error)")
            throw error
        }
    }
    
    func updateListing(_ listing: CarListing, title: String) async throws {
        guard let id = listing.id else {
            print("Listing ID is missing.")
            return
        }
        
        var toUpdate = listing
        toUpdate.title = title
        
        do {
            try await supabase
                .from("CarListing")
                .update(toUpdate)
                .eq("id", value: id)
                .execute()
            print("Listing updated successfully")
            
        } catch {
            print("Error updating listing: \(error)")
            throw error
        }
    }
    
    func deleteListing(at id: Int) async throws {
        do {
            try await supabase
                .from("CarListing")
                .delete()
                .eq("id", value: id)
                .execute()
            
        } catch {
            print("Error deleting listing: \(error)")
            throw error
        }
    }
}
