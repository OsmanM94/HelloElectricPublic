//
//  UploadViewModel.swift
//  Clin
//
//  Created by asia on 25/06/2024.
//

import SwiftUI
import PhotosUI
import Factory

@Observable
final class CreateFormViewModel: ImagePickerProtocol {
    enum ViewState: Equatable {
        case idle
        case loading
        case uploading
        case loaded
        case success(String)
        case error(String)
    }
        
    private(set) var viewState: ViewState = .idle
    private(set) var uploadingProgress: Double = 0.0
    var imageViewState: ImageViewState = .idle
    var isLoadingMake: Bool = false
    
    var selectedImages: [SelectedImage?] = Array(repeating: nil, count: 10)
    var imageSelections: [PhotosPickerItem?] = Array(repeating: nil, count: 10)
    var isLoading: [Bool] = Array(repeating: false, count: 10)
    var evSpecific: [EVModels] = []

    ///DVLA checks
    var registrationNumber: String = ""
    
    // Properties
    var make: String = "Select"
    var model: String = "Select"
    var body: String = "Select"
    var condition: String = "Used"
    var mileage: Double = 500
    var yearOfManufacture: String = "Select"
    var price: Double = 500
    var description: String = ""
    var range: String = "Select"
    var colour: String = "Loading"
    var publicChargingTime: String = "Select"
    var homeChargingTime: String = "Select"
    var batteryCapacity: String = "Select"
    var powerBhp: String = "Select"
    var regenBraking: String = "Select"
    var warranty: String = "Select"
    var serviceHistory: String = "Select"
    var numberOfOwners: String = "Select"
    var isPromoted: Bool = false
    
    var availableModels: [String] = []
    var imagesURLs: [URL] = []
    var thumbnailsURLs: [URL] = []
    
    // Pre-selected properties
    let bodyType: [String] = []
    let yearsOfmanufacture: [String] = []
    let vehicleRange: [String] = []
    let homeCharge: [String] = []
    let publicCharge: [String] = []
    let batteryCap: [String] = []
    let vehicleCondition: [String] = []
    let vehicleRegenBraking: [String] = []
    let vehicleWarranty: [String] = []
    let vehicleServiceHistory: [String] = []
    let vehicleNumberOfOwners: [String] = []
    
    @ObservationIgnored
    @Injected(\.listingService) private var listingService
    @ObservationIgnored
    @Injected(\.prohibitedWordsService) private var prohibitedWordsService
    @ObservationIgnored
    @Injected(\.imageManager) private var imageManager
    @ObservationIgnored
    @Injected(\.dvlaService) private var dvlaService
    @ObservationIgnored
    @Injected(\.supabaseService) private var supabaseService
    
    @MainActor
    func createListing() async {
        viewState = .uploading
        self.uploadingProgress = 0.0
        
        do {
            guard let user = try? await supabaseService.client.auth.session.user else {
                viewState = .error(ListingFormViewStateMessages.noAuthUserFound.message)
                return
            }
            
            let fieldsToCheck = [model, description]
            guard !prohibitedWordsService.containsProhibitedWords(in: fieldsToCheck) else {
                viewState = .error(ListingFormViewStateMessages.inappropriateField.message)
                return
            }
            
            // Calculate the total number of steps (number of images + 1 for the listing creation)
            let nonNilImageItems = selectedImages.compactMap { $0 }
            let totalSteps = nonNilImageItems.count 
            
            try await uploadSelectedImages(for: user.id, totalSteps: totalSteps)
            
            let listingToCreate = Listing(createdAt: Date(), imagesURL: imagesURLs, thumbnailsURL: thumbnailsURLs, make: make, model: model, condition: condition, mileage: mileage, yearOfManufacture: yearOfManufacture, price: price, textDescription: description, range: range, colour: colour, publicChargingTime: publicChargingTime, homeChargingTime: homeChargingTime, batteryCapacity: batteryCapacity, powerBhp: powerBhp, regenBraking: regenBraking, warranty: warranty, serviceHistory: serviceHistory, numberOfOwners: numberOfOwners, userID: user.id)
            
            try await listingService.createListing(listingToCreate)
            
            resetState()
            viewState = .success(ListingFormViewStateMessages.createSuccess.message)
        } catch {
            self.viewState = .error(ListingFormViewStateMessages.generalError.message)
            print(error)
        }
    }
    
    @MainActor
    private func uploadSelectedImages(for userId: UUID, totalSteps: Int) async throws {
        imagesURLs.removeAll()
        thumbnailsURLs.removeAll()
        
        // Filter out non-nil imageItems
        let nonNilImageItems = selectedImages.compactMap { $0 }
        
        guard !nonNilImageItems.isEmpty else {
            print("Selected images are empty")
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
    
    @MainActor
    func sendDvlaRequest() async {
        viewState = .loading
        do {
            let decodedCar = try await dvlaService.fetchCarDetails(registrationNumber: registrationNumber)
            
            if decodedCar.fuelType.uppercased() == "ELECTRICITY" {
                self.yearOfManufacture = "\(decodedCar.yearOfManufacture)"
                self.colour = decodedCar.colour
                viewState = .loaded
            } else {
                self.viewState = .error(ListingFormViewStateMessages.notElectric.message)
            }
        } catch {
            self.viewState = .error(ListingFormViewStateMessages.invalidRegistration.message)
            print(error)
        }
    }
    
    func resetState() {
        registrationNumber = ""
        selectedImages = Array(repeating: nil, count: 10) 
        imageSelections = Array(repeating: nil, count: 10)
        uploadingProgress = 0.0
        imageViewState = .idle
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
            imageViewState = .error(ListingFormViewStateMessages.sensitiveContent.message)
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
            print("Failed to load prohibited words: \(error)")
        }
    }
    
    var totalImageCount: Int {
        selectedImages.compactMap({ $0 }).count
    }
        
    @MainActor
    func fetchMakeAndModels() async {
        if evSpecific.isEmpty || availableModels.isEmpty {
            isLoadingMake = true
            defer { isLoadingMake = false }
            
            do {
                self.evSpecific = try await listingService.fetchMakeModels()
                
                // Set the initial car make
                self.make = evSpecific.first?.make ?? ""
                
                // Update available models based on the fetched car makes
                updateAvailableModels()
                
                print("DEBUG: Fetching make and models")
            } catch {
                print("DEBUG: Failed to fetch car makes and models from Supabase: \(error)")
                viewState = .error(ListingFormViewStateMessages.generalError.message)
            }
        }
    }
        
    func updateAvailableModels() {
        guard let selectedCarMake = evSpecific.first(where: { $0.make == make }) else {
            availableModels = []
            self.model = ""
            return
        }
        
        // Update available models based on the selected make
        availableModels = selectedCarMake.models
        
        // Set the model to the first available one, or clear it if no models are available
        self.model = availableModels.first ?? ""
    }
    
    func loadListingData(listing: Listing) async {}
}



