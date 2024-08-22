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
final class EditFormViewModel: ImagePickerProtocol {
    enum ViewState: Equatable {
        case idle
        case loading
        case uploading
        case success(String)
        case error(String)
    }
    
    private(set) var viewState: ViewState = .idle
    var imageViewState: ImageViewState = .idle
   
    var selectedImages: [SelectedImage?] = Array(repeating: nil, count: 10)
    var imageSelections: [PhotosPickerItem?] = Array(repeating: nil, count: 10)
    var isLoading: [Bool] = Array(repeating: false, count: 10)
        
    private(set) var uploadingProgress: Double = 0.0
    private(set) var imagesURLs: [URL] = []
    private(set) var thumbnailsURLs: [URL] = []
    
    let yearsOfmanufacture: [String] = Array(2010...2030).map { String($0) }
    let vehicleCondition: [String] = ["New", "Used"]
    let vehicleRegenBraking: [String] = ["Yes", "No"]
    let vehicleWarranty: [String] = ["Yes", "No"]
    let vehicleServiceHistory: [String] = ["Yes", "No"]
    let vehicleNumberOfOwners: [String] = ["1", "2", "3", "4+"]
    
    @ObservationIgnored
    @Injected(\.listingService) private var listingService
    @ObservationIgnored
    @Injected(\.prohibitedWordsService) private var prohibitedWordsService
    @ObservationIgnored
    @Injected(\.imageManager) private var imageManager
    @ObservationIgnored
    @Injected(\.dvlaService) private var dvlaService
    @ObservationIgnored
    @Injected(\.httpDataDownloader) private var httpDataDownloader
    @ObservationIgnored
    @Injected(\.supabaseService) private var supabaseService
    
    @MainActor
    func updateUserListing(_ listing: Listing) async {
        viewState = .uploading
        uploadingProgress = 0.0
        do {
            guard let user = try? await supabaseService.client.auth.session.user else {
                viewState = .error(ListingFormViewStateMessages.noAuthUserFound.message)
                return
            }
            
            let fieldsToCheck = [listing.textDescription]
            guard !prohibitedWordsService.containsProhibitedWords(in: fieldsToCheck) else {
                viewState = .error(ListingFormViewStateMessages.inappropriateField.message)
                return
            }
            
            // Calculate the total number of steps
            let nonNilImageItems = selectedImages.compactMap { $0 }
            let totalSteps = nonNilImageItems.count
            
            try await uploadSelectedImages(for: user.id, totalSteps: totalSteps)
            
            var listingToUpdate = Listing(id: listing.id, createdAt: Date(), imagesURL: imagesURLs, thumbnailsURL: thumbnailsURLs, make: listing.make, model: listing.model, condition: listing.condition, mileage: listing.mileage, yearOfManufacture: listing.yearOfManufacture, price: listing.price, textDescription: listing.textDescription, range: listing.range, colour: listing.colour, publicChargingTime: listing.publicChargingTime, homeChargingTime: listing.homeChargingTime, batteryCapacity: listing.batteryCapacity, powerBhp: listing.powerBhp, regenBraking: listing.regenBraking, warranty: listing.warranty, serviceHistory: listing.serviceHistory, numberOfOwners: listing.numberOfOwners, userID: listing.userID)
            
            // Only update images if new ones were uploaded
            if !imagesURLs.isEmpty {
                listingToUpdate.imagesURL = imagesURLs
            }
            if !thumbnailsURLs.isEmpty {
                listingToUpdate.thumbnailsURL = thumbnailsURLs
            }

            try await listingService.updateListing(listingToUpdate)
            
            viewState = .success(ListingFormViewStateMessages.updateSuccess.message)
        } catch {
            viewState = .error(ListingFormViewStateMessages.generalError.message)
        }
    }
    
    @MainActor
    private func uploadSelectedImages(for userId: UUID, totalSteps: Int) async throws {
        imagesURLs.removeAll()
        thumbnailsURLs.removeAll()
        
        // Filter out non-nil imageItems
        let nonNilImageItems = selectedImages.compactMap { $0 }
        
        guard !nonNilImageItems.isEmpty else {
            return
        }
        
        let folderPath = "\(userId)"
        let bucketName = "car_images"
        
        for image in nonNilImageItems {
            let imageURLString = try await imageManager.uploadImage(image.data, from: bucketName, to: folderPath, targetWidth: 350, targetHeight: 350, compressionQuality: 1.0)
            if let urlString = imageURLString, let url = URL(string: urlString) {
                self.imagesURLs.append(url)
            }
            self.uploadingProgress += 1.5 / Double(totalSteps)
        }
        
        if let firstImageItem = nonNilImageItems.first {
            let thumbnailURLString = try await imageManager.uploadImage(firstImageItem.data, from: bucketName, to: folderPath, targetWidth: 120, targetHeight: 120, compressionQuality: 0.4)
            if let thumbUrlString = thumbnailURLString, let url = URL(string: thumbUrlString) {
                self.thumbnailsURLs.append(url)
            }
        }
    }
    
    func resetState() {
        selectedImages = Array(repeating: nil, count: 10)
        imageSelections = Array(repeating: nil, count: 10)
        uploadingProgress = 0.0
        viewState = .idle
    }
    
    func resetImageStateToIdle() {
        imageViewState = .idle
    }
   
    @MainActor
    func loadItem(item: PhotosPickerItem, at index: Int) async {
        isLoading[index] = true
        defer { isLoading[index] = false }
        let result = await imageManager.loadItem(item: item, analyze: true)
        
        switch result {
        case .success(let selectedImage):
            let newSelectedImage = SelectedImage(data: selectedImage.data, id: UUID().uuidString, photosPickerItem: item)
            selectedImages[index] = newSelectedImage
        case .sensitiveContent:
            imageViewState = .sensitiveContent(ListingFormViewStateMessages.sensitiveContent.message)
        case .analysisError:
            imageViewState = .sensitiveApiNotEnabled
        case .loadingError:
            imageViewState = .error(ListingFormViewStateMessages.generalError.message)
        }
    }
    
    func deleteImage(id: String) {
        if let index = selectedImages.firstIndex(where: { $0?.id == id }) {
            selectedImages[index] = nil
            imageSelections[index] = nil
        }
    }
    
    func loadProhibitedWords() async {
        do {
            try await prohibitedWordsService.loadProhibitedWords()
        } catch {
            print("DEBUG: Failed to load prohibited words: \(error)")
        }
    }
    
    var totalImageCount: Int {
        selectedImages.compactMap({ $0 }).count
    }
            
    @MainActor
    func loadImagesFromURLs(_ urls: [URL]) async {
        let limitedURLs = urls.prefix(10)
        
        for (urlIndex, url) in limitedURLs.enumerated() {
            guard urlIndex < selectedImages.count else { return }
            
            isLoading[urlIndex] = true
            defer { isLoading[urlIndex] = false }
            
            do {
                let data = try await httpDataDownloader.fetchURL(from: url)
                guard let selectedImage = SelectedImage(data: data, id: url.absoluteString, photosPickerItem: nil) else {
                    print("DEBUG: Failed to create SelectedImage from data for URL: \(url)")
                    continue
                }
                selectedImages[urlIndex] = selectedImage
            } catch {
                print("DEBUG: Error downloading image data from URL: \(url) - \(error)")
                viewState = .error(ListingFormViewStateMessages.errorDownloadingImages.message)
            }
        }
    }
    
    @MainActor
    func retrieveImages(listing: Listing) async {
        guard let id = listing.id else {
            viewState = .error(ListingFormViewStateMessages.generalError.message)
            return
        }
        
        do {
            // Fetch listing from the service
            let fetchedListing = try await listingService.loadListing(id: id)
            
            // Append new image URLs without removing existing ones
            let newImageUrls = fetchedListing.imagesURL.filter { !imagesURLs.contains($0) }
            imagesURLs.append(contentsOf: newImageUrls)
            
            // Update thumbnails similarly
            let newThumbnailUrls = fetchedListing.thumbnailsURL.filter { !thumbnailsURLs.contains($0) }
            thumbnailsURLs.append(contentsOf: newThumbnailUrls)
            
            // Convert image URLs to SelectedImage instances and update the images
            await loadImagesFromURLs(newImageUrls)
            
        } catch {
            print("DEBUG: Failed to fetch listing or load images: \(error)")
            viewState = .error(ListingFormViewStateMessages.generalError.message)
        }
    }

}

