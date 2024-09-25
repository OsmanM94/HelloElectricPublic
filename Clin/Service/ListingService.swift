//
//  CarListingService.swift
//  Clin
//
//  Created by asia on 24/06/2024.
//

import Foundation
import Factory

final class ListingService: ListingServiceProtocol {
    @Injected(\.databaseService) private var databaseService
        
    func loadListing(id: Int) async throws -> Listing {
        try await databaseService
            .loadByID(
                from: "car_listing",
                id: id
            )
    }
    
    func refreshListings(id: Int) async throws {
        let now = Date()
        
        // Update the listing
        try await databaseService.update(["created_at": now], in: "car_listing", id: id)
    }
    
    func loadUserListings(userID: UUID) async throws -> [Listing] {
        try await databaseService
            .loadMultipleItems(
                from: "car_listing",
                orderBy: "created_at",
                ascending: false,
                field: "user_id",
                uuid: userID
            )
    }
    
    func loadModels() async throws -> [EVModels] {
        try await databaseService
            .loadAll(from: "ev_make", orderBy: "make", ascending: true)
    }
    
    func loadLocations() async throws -> [Cities] {
        try await databaseService
            .loadAll(from: "uk_cities", orderBy: "city", ascending: true)
    }
    
    func loadEVfeatures() async throws -> [EVFeatures] {
        try await databaseService
            .loadAll(from: "ev_features", orderBy: "id", ascending: true)
    }
    
    func createListing(_ listing: Listing) async throws {
        try await databaseService
            .insert(
                listing,
                into: "car_listing"
            )
    }
    
    func updateListing(_ listing: Listing) async throws {
        guard let id = listing.id else {
            print("DEBUG: Listing ID is missing.")
            return
        }
        try await databaseService.update(listing, in: "car_listing", id: id)
    }
    
    func deleteListing(at id: Int) async throws {
        try await databaseService
            .delete(
                from: "car_listing",
                id: id
            )
    }
    
    func loadListingsByVehicleType(type: [String], column: String, from: Int, to: Int) async throws -> [Listing] {
        try await databaseService
            .loadPaginatedDataWithListFilter(
                from: "car_listing",
                filter: column, values: type,
                orderBy: "is_promoted",
                orderBy2: "created_at",
                ascending: false,
                from: from,
                to: to
            )
    }
        
    func loadFilteredListings(vehicleType: [String], orderBy: String, ascending: Bool, from: Int, to: Int) async throws -> [Listing] {
        try await databaseService.loadPaginatedDataWithListFilter(
            from: "car_listing",
            filter: "body_type",
            values: vehicleType,
            orderBy: orderBy,
            orderBy2: "created_at",
            ascending: ascending,
            from: from,
            to: to
        )
    }
}

