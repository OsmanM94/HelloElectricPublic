//
//  CarListingService.swift
//  Clin
//
//  Created by asia on 24/06/2024.
//

import Foundation


struct ListingService: ListingServiceProtocol {
  
    func fetchListings(from: Int, to: Int) async throws -> [Listing] {
        do {
            let listings: [Listing] = try await Supabase.shared.client
                .from("car_listing")
                .select()
                .order("created_at", ascending: false)
                .range(from: from, to: to)
                .execute()
                .value
            print("DEBUG: Public listings retrieved succesfully.")
            return listings
        } catch {
            throw error
        }
    }
    
    func fetchUserListings(userID: UUID) async throws -> [Listing] {
        do {
            let listings: [Listing] = try await Supabase.shared.client
                .from("car_listing")
                .select()
                .eq("user_id", value: userID)
                .order("created_at", ascending: false)
                .execute()
                .value
            print("DEBUG: User listings retrieved succesfully.")
            return listings
        } catch {
            throw error
        }
    }
        
    func createListing(_ listing: Listing) async throws {
        do {
            try await Supabase.shared.client
                .from("car_listing")
                .insert(listing)
                .execute()
            print("DEBUG: Listing created successfully.")
        } catch {
            throw error
        }
    }
    
    func updateListing(_ listing: Listing) async throws {
        guard let id = listing.id else {
            print("DEBUG: Listing ID is missing.")
            return
        }
        do {
            try await Supabase.shared.client
                .from("car_listing")
                .update(listing)
                .eq("id", value: id)
                .execute()
            print("DEBUG: Listing updated succesfully.")
        } catch {
            throw error
        }
    }
    
    func deleteListing(at id: Int) async throws {
        do {
            try await Supabase.shared.client
                .from("car_listing")
                .delete()
                .eq("id", value: id)
                .execute()
            print("DEBUG: Listing deleted successfully.")
        } catch {
            throw error
        }
    }
}

