//
//  Protocols.swift
//  Clin
//
//  Created by asia on 08/08/2024.
//

import Foundation

protocol ListingServiceProtocol {
    func fetchListings(from: Int, to: Int) async throws -> [Listing]
    func fetchUserListings(userID: UUID) async throws -> [Listing]
    func createListing(_ listing: Listing) async throws
    func updateListing(_ listing: Listing) async throws
    func deleteListing(at id: Int) async throws
}

protocol FavouriteServiceProtocol {
    func fetchUserFavourites(userID: UUID) async throws -> [Favourite]
    func addToFavorites(_ favourite: Favourite) async throws
    func removeFromFavorites(_ favourite: Favourite, for userID: UUID) async throws
}
