//
//  CarListingService.swift
//  Clin
//
//  Created by asia on 24/06/2024.
//

import Foundation

struct ListingService: ListingServiceProtocol {
    private let databaseService: DatabaseServiceProtocol
    
    init(databaseService: DatabaseServiceProtocol) {
        self.databaseService = databaseService
        print("DEBUG: Did init listing service")
    }
    
    func fetchPaginatedListings(from: Int, to: Int) async throws -> [Listing] {
        try await databaseService.fetchPagination(from: "car_listing", orderBy: "created_at", ascending: false, from: from, to: to)
    }
    
    func fetchListing(id: Int) async throws -> Listing {
        try await databaseService.fetchByID(from: "car_listing", id: id)
    }
    
    func fetchMakeModels() async throws -> [CarMake] {
        try await databaseService.fetchAll(from: "car_make")
    }
    
    func fetchUserListings(userID: UUID) async throws -> [Listing] {
        try await databaseService.fetchByField(from: "car_listing", field: "user_id", value: userID)
    }
    
    func createListing(_ listing: Listing) async throws {
        try await databaseService.insert(listing, into: "car_listing")
    }
    
    func updateListing(_ listing: Listing) async throws {
        guard let id = listing.id else {
            print("DEBUG: Listing ID is missing.")
            return
        }
        try await databaseService.update(listing, in: "car_listing", id: id)
    }
    
    func deleteListing(at id: Int) async throws {
        try await databaseService.delete(from: "car_listing", id: id)
    }
}
