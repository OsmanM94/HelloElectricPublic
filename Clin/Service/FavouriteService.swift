//
//  FavouriteService.swift
//  Clin
//
//  Created by asia on 09/08/2024.
//

import Foundation

struct FavouriteService: FavouriteServiceProtocol {
    
    private let databaseService: DatabaseServiceProtocol
    
    init(databaseService: DatabaseServiceProtocol) {
        self.databaseService = databaseService
        print("DEBUG: Did init favourite service")
    }
        
    func fetchUserFavourites(userID: UUID) async throws -> [Favourite] {
        try await databaseService.fetchByField(from: "favourite_listing", field: "user_id", value: userID)
    }
    
    func addToFavorites(_ favourite: Favourite) async throws {
        try await databaseService.insert(favourite, into: "favourite_listing")
    }
    
    
    func removeFromFavorites(_ favourite: Favourite, for userID: UUID) async throws {
        try await databaseService
            .deleteByField(
                from: "favourite_listing",
                field: "listing_id",
                value: favourite.listingID,
                field2: "user_id",
                value2: userID
            )
    }
}

