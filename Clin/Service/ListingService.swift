//
//  CarListingService.swift
//  Clin
//
//  Created by asia on 24/06/2024.
//

import Foundation

protocol ListingServiceProtocol {
    func fetchListings() async throws -> [Listing]
    func fetchUserListings(userID: UUID) async throws -> [Listing]
    func createListing(_ listing: Listing) async throws
    func updateListing(_ listing: Listing) async throws
    func deleteListing(at id: Int) async throws
}

struct ListingService: ListingServiceProtocol {
  
    init() {}
    
    func fetchListings() async throws -> [Listing] {
        do {
            let listings: [Listing] = try await Supabase.shared.client
                .from("car_listing")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value
            return listings
        } catch {
            print("DEBUG: Error fetching listings: \(error)")
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
            return listings
        } catch {
            print("Error fetching user listings: \(error)")
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
            print("DEBUG: Error creating listing: \(error)")
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
        } catch {
            print("DEBUG: Error updating listing: \(error)")
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
        } catch {
            print("Error deleting listing: \(error)")
            throw error
        }
    }
}



//func fetchListings() async throws -> [Listing] {
//    do {
//        let listings: [Listing] = try await Supabase.shared.client
//            .from("car_listing")
//            .select()
//            .order("created_at", ascending: false)
//            .limit(50)
//            .execute()
//            .value
//        return listings
//    } catch {
//        print("Error fetching listings: \(error)")
//        throw error
//    }
//}
