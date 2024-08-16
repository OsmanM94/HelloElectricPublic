//
//  Protocols.swift
//  Clin
//
//  Created by asia on 08/08/2024.
//
import SwiftUI
import PhotosUI

//protocol ListingServiceProtocol {
//    func fetchPaginatedListings(from: Int, to: Int) async throws -> [Listing]
//    func fetchListings(id: Int) async throws -> Listing
//    func fetchUserListings(userID: UUID) async throws -> [Listing]
//    func fetchMakeModels() async throws -> [CarMake]
//    func createListing(_ listing: Listing) async throws
//    func updateListing(_ listing: Listing) async throws
//    func deleteListing(at id: Int) async throws
//}

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

protocol ImagePickerProtocol: ObservableObject {
    var selectedImages: [SelectedImage?] { get set }
    var imageSelections: [PhotosPickerItem?] { get set }
    var isLoading: [Bool] { get set }
    var imageViewState: ImageViewState { get set }
    
    func loadItem(item: PhotosPickerItem, at index: Int) async
    func deleteImage(id: String)
    func loadListingData(listing: Listing) async
    func resetStateToIdle()
}

protocol HTTPDataDownloaderProtocol {
    func fetchData <T: Decodable>(as type: T.Type, endpoint: String) async throws -> T
    func postData<T: Decodable, U: Encodable>(as type: T.Type, to endpoint: String, body: U, headers: [String: String]) async throws -> T
    func fetchURL(from url: URL) async throws -> Data
}
