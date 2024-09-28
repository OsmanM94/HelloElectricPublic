//
//  FavouriteService.swift
//  Clin
//
//  Created by asia on 09/08/2024.
//

import Foundation
import Factory

final class FavouriteService: FavouriteServiceProtocol {
    @Injected(\.databaseService) var databaseService: DatabaseServiceProtocol
    
    func loadUserFavourites(userID: UUID) async throws -> [Favourite] {
        try await databaseService
            .loadItemsByField(
                from: "favourite_listing",
                orderBy: "refreshed_at",
                ascending: false,
                field: "user_id",
                uuid: userID
            )
    }
    
    func addToFavorites(_ favourite: Favourite) async throws {
        try await databaseService.insertItem(favourite, into: "favourite_listing")
    }
    
    func removeFromFavorites(_ favourite: Favourite, for userID: UUID) async throws {
        try await databaseService
            .deleteItemByFields(
                from: "favourite_listing",
                field: "listing_id",
                value: favourite.listingID,
                field2: "user_id",
                value2: userID
            )
    }
}

