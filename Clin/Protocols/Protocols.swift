//
//  Protocols.swift
//  Clin
//
//  Created by asia on 08/08/2024.
//
import SwiftUI
import PhotosUI
import Supabase

protocol DatabaseServiceProtocol {
    func loadPaginatedItems<T: Decodable>(from table: String, orderBy: String, ascending: Bool, from: Int, to: Int) async throws -> [T]
    func loadPaginatedItemsWithListFilter<T: Decodable>(from table: String, filter: String, values: [String], orderBy: String, orderBy2: String, ascending: Bool, from: Int, to: Int) async throws -> [T]
    func searchPaginatedItemsWithOrFilter<T: Decodable> (from table: String, filter: String, from: Int, to: Int, orderBy: String, ascending: Bool) async throws -> [T]
    func searchItemsWithComplexFilter<T: Decodable>(from table: String,filters: [String: Any],from: Int,to: Int, orderBy:String, ascending: Bool) async throws -> [T]
    func loadAllItems<T: Decodable>(from table: String, orderBy: String, ascending: Bool) async throws -> [T]
    func loadItemByID<T: Decodable>(from table: String, id: Int) async throws -> T
    func loadItemsByField<T: Decodable>(from table: String, orderBy: String, ascending: Bool, field: String, uuid: UUID) async throws -> [T]
    func loadSingleItemByField<T: Decodable>(from table: String, field: String, uuid: UUID) async throws -> T
    func insertItem<T: Encodable>(_ item: T, into table: String) async throws
    func updateItemByID<T: Encodable>(_ item: T, in table: String, id: Int) async throws
    func updateItemByUserID<T: Encodable>(_ item: T, in table: String, userID: UUID) async throws
    func deleteItemByID(from table: String, id: Int) async throws
    func deleteItemByFields(from table: String, field: String , value: Int, field2: String, value2: UUID) async throws
    func deleteItemFromStorage(from table: String, path: [String]) async throws
}

protocol AuthServiceProtocol {
    func signOut() async throws
    func signInWithApple(idToken: String) async throws
    func deleteUserTable(from table: String, userId: UUID) async throws
    func deleteUserProfile(userId: UUID) async throws
    func deleteUserImages(userId: UUID) async throws
    func setupAuthStateListener(completion: @Sendable @escaping (AuthChangeEvent, Session?) -> Void) async throws
    func getCurrentUser() async throws -> User?
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
    func loadListingsByVehicleType(type: [String], column: String, from: Int, to: Int) async throws -> [Listing]
    func loadFilteredListings(vehicleType: [String], orderBy: String, ascending: Bool, from: Int, to: Int) async throws -> [Listing]
    func refreshListings(id: Int) async throws
    func deleteImagesFromStorage(from table: String, path: [String]) async throws
    func getCurrentUser() async throws -> User?
}

protocol EVDatabaseServiceProtocol {
    func searchEVs(searchText: String, from: Int, to: Int) async throws -> [EVDatabase]
    func loadEVs(filter: DatabaseFilter, from: Int, to: Int) async throws -> [EVDatabase]
}

protocol FavouriteServiceProtocol {
    func loadUserFavourites(userID: UUID) async throws -> [Favourite]
    func addToFavorites(_ favourite: Favourite) async throws
    func removeFromFavorites(_ favourite: Favourite, for userID: UUID) async throws
    func getCurrentUser() async throws -> User?
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
    func containsProhibitedWords(in texts: [String]) -> Bool
    func containsProhibitedWordsDictionary(in fields: [String: String]) -> [String: Bool]
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

protocol ImageManagerFormProtocol: ImagePickerProtocol {
    var selectedImages: [SelectedImage?] { get set }
    var hasUserInitiatedChanges: Bool { get }
    func updateAfterReorder()
}

protocol httpClientProtocol {
    func loadData <T: Decodable>(as type: T.Type, endpoint: String, headers: [String: String]?) async throws -> T
    func postData<T: Decodable, U: Encodable>(as type: T.Type, to endpoint: String, body: U, headers: [String: String]) async throws -> T
    func loadURL(from url: URL) async throws -> Data
}

extension httpClientProtocol {
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
