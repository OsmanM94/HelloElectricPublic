//
//  Protocols.swift
//  Clin
//
//  Created by asia on 08/08/2024.
//
import SwiftUI
import PhotosUI

protocol DatabaseServiceProtocol {
    func fetchPagination<T: Decodable>(from table: String, orderBy: String, ascending: Bool, from: Int, to: Int) async throws -> [T]
    func fetchAll<T: Decodable>(from table: String) async throws -> [T]
    func fetchByID<T: Decodable>(from table: String, id: Int) async throws -> T
    func fetchByField<T: Decodable>(from table: String, field: String, value: UUID) async throws -> [T]
    func insert<T: Encodable>(_ item: T, into table: String) async throws
    func update<T: Encodable>(_ item: T, in table: String, id: Int) async throws
    func delete(from table: String, id: Int) async throws
    func deleteByField(from table: String, field: String , value: Int, field2: String, value2: UUID) async throws
}

protocol ListingServiceProtocol {
    func fetchPaginatedListings(from: Int, to: Int) async throws -> [Listing]
    func fetchListing(id: Int) async throws -> Listing
    func fetchMakeModels() async throws -> [CarMake]
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

protocol DvlaServiceProtocol {
    func fetchCarDetails(registrationNumber: String) async throws -> Dvla
}
