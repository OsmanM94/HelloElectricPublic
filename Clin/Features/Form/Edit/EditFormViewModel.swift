//
//  ListingFormEditViewModel.swift
//  Clin
//
//  Created by asia on 27/07/2024.
//
import SwiftUI
import PhotosUI
import Factory

@Observable
final class EditFormViewModel {
    // MARK: - Enums
    enum ViewState: Equatable {
        case idle, loading, uploading, success(String), error(String)
    }
    
    enum SubFormViewState: Equatable {
        case loading, loaded, error(String)
    }
    
    // MARK: - Observable properties
    // View States
    private(set) var viewState: ViewState = .idle
    private(set) var subFormViewState: SubFormViewState = .loading
    
    var isRetrievingImage: Bool = false
    var isPromoted: Bool = false
    
    // MARK: - Dependencies
    // Services
    @ObservationIgnored @Injected(\.listingService) private var listingService
    @ObservationIgnored @Injected(\.supabaseService) private var supabaseService
    // ViewModels
    @ObservationIgnored @Injected(\.editFormImageManager) var imageManager
    @ObservationIgnored @Injected(\.editFormDataLoader) var dataLoader
    
    // MARK: - Main Actor functions
    @MainActor
    func loadBulkData() async {
        do {
            try await dataLoader.loadBulkData()
            self.subFormViewState = .loaded
        } catch {
            self.subFormViewState = .error(MessageCenter.MessageType.generalError.message)
        }
    }
        
    @MainActor
    func updateUserListing(_ listing: Listing) async {
        viewState = .uploading
        do {
            guard let user = try? await supabaseService.client.auth.session.user else {
                viewState = .error(MessageCenter.MessageType.noAuthUserFound.message)
                return
            }
            
            let fieldToCheck = listing.textDescription
            guard !dataLoader.prohibitedWordsService.containsProhibitedWord(fieldToCheck) else {
                viewState = .error(MessageCenter.MessageType.inappropriateField.message)
                return
            }
            
            try await imageManager.uploadSelectedImages(for: user.id)
            
            var listingToUpdate = listing
            
            // Replace existing image URLs with new ones if uploaded
            if !imageManager.imagesURLs.isEmpty {
                listingToUpdate.imagesURL = imageManager.imagesURLs
            }
            if !imageManager.thumbnailsURLs.isEmpty {
                listingToUpdate.thumbnailsURL = imageManager.thumbnailsURLs
            }

            try await listingService.updateListing(listingToUpdate)
            
            viewState = .success(MessageCenter.MessageType.updateSuccess.message)
        } catch {
            print("Error updating user listing \(error)")
            viewState = .error(MessageCenter.MessageType.generalError.message)
        }
    }
    
    @MainActor
    func retrieveImages(listing: Listing) async {
        guard let id = listing.id else {
            viewState = .error(MessageCenter.MessageType.noAuthUserFound.message)
            return
        }
        self.isRetrievingImage = true
        do {
            try await imageManager.retrieveImages(listing: listing, id: id)
            
            self.isRetrievingImage = false
        } catch {
            viewState = .error(MessageCenter.MessageType.errorDownloadingImages.message)
        }
    }
    
    @MainActor
    func resetState() {
        subFormViewState = .loading
        viewState = .idle
    }
}

@Observable
final class EditFormImageManager: ImagePickerProtocol {
    var selectedImages: [SelectedImage?] = Array(repeating: nil, count: 10)
    var imageSelections: [PhotosPickerItem?] = Array(repeating: nil, count: 10)
    var isLoadingImages: [Bool] = Array(repeating: false, count: 10)
    
    private(set) var hasUserInitiatedChanges: Bool = false
    private(set) var imagesURLs: [URL] = []
    private(set) var thumbnailsURLs: [URL] = []
    private(set) var uploadingProgress: Double = 0.0
    
    // New property to track changed images
    private var changedImageIndices: Set<Int> = []
    
    // MARK: - Image view state
    var imageViewState: ImageViewState = .idle
    
    // MARK: - Dependencies
    @ObservationIgnored @Injected(\.imageManager) var imageManager
    @ObservationIgnored @Injected(\.httpClient) var httpClient
    @ObservationIgnored @Injected(\.listingService) var listingService
    
    // MARK: - Main Actor functions
    @MainActor
    func loadItem(item: PhotosPickerItem, at index: Int) async {
        isLoadingImages[index] = true
        defer { isLoadingImages[index] = false }
        
        let result = await imageManager.loadItem(item: item, analyze: true)
        
        switch result {
        case .success(let selectedImage):
            let newSelectedImage = SelectedImage(data: selectedImage.data, id: UUID().uuidString, photosPickerItem: item)
            selectedImages[index] = newSelectedImage
            hasUserInitiatedChanges = true
            changedImageIndices.insert(index)  // Mark this index as changed
            
        case .sensitiveContent:
            imageViewState = .error(MessageCenter.MessageType.sensitiveContent.message)
            
        case .analysisError:
            imageViewState = .sensitiveApiNotEnabled
            
        case .loadingError:
            imageViewState = .error(MessageCenter.MessageType.generalError.message)
        }
    }
    
    // MARK: - Functions
    func deleteImage(id: String) {
        if let index = selectedImages.firstIndex(where: { $0?.id == id }) {
            selectedImages[index] = nil
            imageSelections[index] = nil
            hasUserInitiatedChanges = true
            changedImageIndices.insert(index)  // Mark this index as changed
        }
    }
    
    func resetChangeFlag() {
        hasUserInitiatedChanges = false
        changedImageIndices.removeAll()  // Reset changed indices
    }
    
    func retrieveImages(listing: Listing, id: Int) async throws {
        do {
            // Load listing from the service
            let loadedListing = try await listingService.loadListing(id: id)
            
            // Append new image URLs without removing existing ones
            let newImageUrls = loadedListing.imagesURL.filter { !imagesURLs.contains($0) }
            imagesURLs.append(contentsOf: newImageUrls)
            
            // Update thumbnails similarly
            let newThumbnailUrls = loadedListing.thumbnailsURL.filter { !thumbnailsURLs.contains($0) }
            thumbnailsURLs.append(contentsOf: newThumbnailUrls)
            
            // Convert image URLs to SelectedImage instances and update the images
            await loadImagesFromURLs(newImageUrls)
        } catch {
            print("DEBUG: Failed to load listing or load images: \(error)")
        }
    }

    func resetImageStateToIdle() {
        imageViewState = .idle
    }
    
    var totalImageCount: Int {
        selectedImages.compactMap({ $0 }).count
    }
    
    func resetImageState() {
        selectedImages = Array(repeating: nil, count: 10)
        imageSelections = Array(repeating: nil, count: 10)
        imagesURLs.removeAll()
        thumbnailsURLs.removeAll()
        uploadingProgress = 0.0
        imageViewState = .idle
    }
    
    func uploadSelectedImages(for userId: UUID) async throws {
        let folderPath = "\(userId)"
        let bucketName = "car_images"
        
        var newImagesURLs: [URL] = []
        var newThumbnailsURLs: [URL] = []
        
        for (index, image) in selectedImages.enumerated() {
            if let image = image, changedImageIndices.contains(index) {
                let imageURLString = try await imageManager.uploadImage(image.data, from: bucketName, to: folderPath, targetWidth: 500, targetHeight: 500, compressionQuality: 0.8)
                if let urlString = imageURLString, let url = URL(string: urlString) {
                    newImagesURLs.append(url)
                }
                
                // Only update thumbnail if it's the first image or the first image changed
                if index == 0 || (changedImageIndices.contains(0) && newThumbnailsURLs.isEmpty) {
                    let thumbnailURLString = try await imageManager.uploadImage(image.data, from: bucketName, to: folderPath, targetWidth: 130, targetHeight: 130, compressionQuality: 0.6)
                    if let thumbUrlString = thumbnailURLString, let url = URL(string: thumbUrlString) {
                        newThumbnailsURLs.append(url)
                    }
                }
                
                self.uploadingProgress += 1.0 / Double(changedImageIndices.count)
            } else if image != nil {
                // no changes detected, keep existing urls
                if index < imagesURLs.count {
                    newImagesURLs.append(imagesURLs[index])
                }
                if index == 0 && !thumbnailsURLs.isEmpty {
                    newThumbnailsURLs = thumbnailsURLs
                }
            }
        }
        
        // Update the URLs with the new ones
        self.imagesURLs = newImagesURLs
        self.thumbnailsURLs = newThumbnailsURLs
        
        // Reset changed indices after upload
        changedImageIndices.removeAll()
    }
    
    // MARK: - Private functions
    private func loadImagesFromURLs(_ urls: [URL]) async {
        let limitedURLs = urls.prefix(10)
        
        for (urlIndex, url) in limitedURLs.enumerated() {
            guard urlIndex < selectedImages.count else { return }
            
            isLoadingImages[urlIndex] = true
            defer { isLoadingImages[urlIndex] = false }
            
            do {
                let data = try await httpClient.loadURL(from: url)
                guard let selectedImage = SelectedImage(data: data, id: url.absoluteString, photosPickerItem: nil) else { return }
                
                selectedImages[urlIndex] = selectedImage
            } catch {
                print("DEBUG: Error downloading image data from URL: \(url) - \(error)")
            }
        }
    }
}

@Observable
final class EditFormDataLoader {
    var availableLocations: [String] = []
    var bodyTypeOptions: [String] = []
    var yearOptions: [String] = []
    var conditionOptions: [String] = []
    var rangeOptions: [String] = []
    var colourOptions: [String] = []
    var publicChargingTimeOptions: [String] = []
    var homeChargingTimeOptions: [String] = []
    var batteryCapacityOptions: [String] = []
    var powerBhpOptions: [String] = []
    var regenBrakingOptions: [String] = []
    var warrantyOptions: [String] = []
    var serviceHistoryOptions: [String] = []
    var numberOfOwnersOptions: [String] = []
    
    // MARK: - Dependencies
    @ObservationIgnored @Injected(\.listingService) var listingService
    @ObservationIgnored @Injected(\.prohibitedWordsService) var prohibitedWordsService
    
    // MARK: - Functions
    func loadBulkData() async throws {
        try await loadProhibitedWords()
        try await loadFeatures()
        try await loadLocations()
    }
    
    // MARK: - Private functions
    private func loadProhibitedWords() async throws {
        do {
            try await prohibitedWordsService.loadProhibitedWords()
        } catch {
            throw error
        }
    }
    
    private func loadLocations() async throws {
        let loadedData = try await listingService.loadLocations()
        availableLocations = ["Select"] + loadedData.compactMap { $0.city }
    }
    
    private func loadFeatures() async throws {
        let loadedData = try await listingService.loadEVfeatures()
        populateFeatures(with: loadedData)
    }
    
    private func populateFeatures(with loadedData: [EVFeatures]) {
        bodyTypeOptions = ["Select"] + loadedData.flatMap { $0.bodyType }
        yearOptions = ["Select"] + loadedData.flatMap { $0.yearOfManufacture }
        conditionOptions = ["Select"] + loadedData.flatMap { $0.condition }
        rangeOptions = ["Select"] + loadedData.flatMap { $0.range }
        homeChargingTimeOptions = ["Select"] + loadedData.flatMap { $0.homeChargingTime }
        publicChargingTimeOptions = ["Select"] + loadedData.flatMap { $0.publicChargingTime }
        batteryCapacityOptions = ["Select"] + loadedData.flatMap { $0.batteryCapacity }
        regenBrakingOptions = ["Select"] + loadedData.flatMap { $0.regenBraking }
        warrantyOptions = ["Select"] + loadedData.flatMap { $0.warranty }
        serviceHistoryOptions = ["Select"] + loadedData.flatMap { $0.serviceHistory }
        numberOfOwnersOptions = ["Select"] + loadedData.flatMap { $0.owners }
        powerBhpOptions = ["Select"] + loadedData.flatMap { $0.powerBhp }
        colourOptions = ["Select"] + loadedData.flatMap { $0.colours }
    }
}

