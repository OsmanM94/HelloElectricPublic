//
//  Protocols.swift
//  Clin
//
//  Created by asia on 08/08/2024.
//
import SwiftUI
import PhotosUI

protocol DatabaseServiceProtocol {
    func loadPaginatedData<T: Decodable>(from table: String, orderBy: String, ascending: Bool, from: Int, to: Int) async throws -> [T]
    func loadPaginatedDataWithListFilter<T: Decodable>(from table: String, filter: String, values: [String], orderBy: String, orderBy2: String, ascending: Bool, from: Int, to: Int) async throws -> [T]
    func searchPaginatedDataWithOrFilter<T: Decodable> (from table: String, filter: String, from: Int, to: Int, orderBy: String, ascending: Bool) async throws -> [T]
    func searchWithComplexFilter<T: Decodable>(from table: String,filters: [String: Any],from: Int,to: Int, orderBy:String, ascending: Bool) async throws -> [T]
    func loadAll<T: Decodable>(from table: String, orderBy: String, ascending: Bool) async throws -> [T]
    func loadByID<T: Decodable>(from table: String, id: Int) async throws -> T
    func loadMultipleItems<T: Decodable>(from table: String, orderBy: String, ascending: Bool, field: String, uuid: UUID) async throws -> [T]
    func loadSingleItem<T: Decodable>(from table: String, field: String, uuid: UUID) async throws -> T
    func insert<T: Encodable>(_ item: T, into table: String) async throws
    func update<T: Encodable>(_ item: T, in table: String, id: Int) async throws
    func updateByUUID<T: Encodable>(_ item: T, in table: String, userID: UUID) async throws
    func delete(from table: String, id: Int) async throws
    func deleteByField(from table: String, field: String , value: Int, field2: String, value2: UUID) async throws
}

protocol ListingServiceProtocol {
    func loadListing(id: Int) async throws -> Listing
    func loadUserListings(userID: UUID) async throws -> [Listing]
    func createListing(_ listing: Listing) async throws
    func updateListing(_ listing: Listing) async throws
    func deleteListing(at id: Int) async throws
    func loadModels() async throws -> [EVModels]
    func loadLocations() async throws -> [Cities]
    func loadEVfeatures() async throws -> [EVFeatures]
//    func searchListings(vehicleType: VehicleType, from: Int, to: Int) async throws -> [Listing]
    func loadListingsByVehicleType(type: [String], column: String, from: Int, to: Int) async throws -> [Listing]
    func loadFilteredListings(vehicleType: [String], orderBy: String, ascending: Bool, from: Int, to: Int) async throws -> [Listing]
}

protocol EVDatabaseServiceProtocol {
    func loadPaginatedEVs(from: Int, to: Int) async throws -> [EVDatabase]
}

protocol FavouriteServiceProtocol {
    func loadUserFavourites(userID: UUID) async throws -> [Favourite]
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
    func containsProhibitedWords(in fields: [String: String]) -> [String: Bool]
}

protocol ImagePickerProtocol: Observable {
    var selectedImages: [SelectedImage?] { get set }
    var imageSelections: [PhotosPickerItem?] { get set }
    var isLoadingImages: [Bool] { get set }
    var imageViewState: ImageViewState { get set }
    
    func loadItem(item: PhotosPickerItem, at index: Int) async
    func deleteImage(id: String)
    func retrieveImages(listing: Listing, id: Int) async throws
    func resetImageStateToIdle()
}

protocol HTTPDataDownloaderProtocol {
    func loadData <T: Decodable>(as type: T.Type, endpoint: String, headers: [String: String]?) async throws -> T
    func postData<T: Decodable, U: Encodable>(as type: T.Type, to endpoint: String, body: U, headers: [String: String]) async throws -> T
    func fetchURL(from url: URL) async throws -> Data
}

extension HTTPDataDownloaderProtocol {
    func loadData<T: Decodable>(as type: T.Type, endpoint: String) async throws -> T {
        try await loadData(as: type, endpoint: endpoint, headers: nil)
    }
}

protocol DvlaServiceProtocol {
    func loadDetails(registrationNumber: String) async throws -> Dvla
}

protocol ProfileServiceProtocol {
    func loadProfile(for userID: UUID) async throws -> Profile
    func updateProfile(_ profile: Profile) async throws
    func getCurrentUserID() async throws -> UUID
}

protocol SearchServiceProtocol {
    func loadModels() async throws -> [EVModels]
    func loadCities() async throws -> [Cities]
    func loadEVfeatures() async throws -> [EVFeatures]
    func searchWithPaginationAndFilter(or: String, from: Int, to: Int) async throws -> [Listing]
    func searchFilteredItems(filters: [String: Any], from: Int, to: Int) async throws -> [Listing]
}
