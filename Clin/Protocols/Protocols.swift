//
//  Protocols.swift
//  Clin
//
//  Created by asia on 08/08/2024.
//
import SwiftUI
import PhotosUI

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

protocol ImageManagerProtocol {
    var isHeicSupported: Bool { get }
    func analyzeImage(_ data: Data) async -> AnalysisState
    func uploadImage(_ data: Data, from bucket: String, to folder: String, targetWidth: Int, targetHeight: Int, compressionQuality: CGFloat) async throws -> String?
    func deleteImage(path: String, from folder: String) async throws
    func loadItem(item: PhotosPickerItem, analyze: Bool) async -> ImageLoadResult
}

protocol ProhibitedWordsServiceProtocol {
    var prohibitedWords: Set<String> { get }
    func loadProhibitedWords() async throws
    func containsProhibitedWord(_ text: String) -> Bool
    func containsProhibitedWords(in fields: [String]) -> Bool
}
