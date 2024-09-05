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
   
    // MARK: - Enums
    enum ViewState: Equatable {
        case idle, loading, uploading, loaded, success(String), error(String)
    }
    
    enum SubFormViewState: Equatable {
        case loading, loaded, error(String)
    }
        
    // MARK: - Observable Properties
    // View States
    private(set) var viewState: ViewState = .idle
    private(set) var subFormViewState: SubFormViewState = .loaded
    private(set) var uploadingProgress: Double = 0.0
    var imageViewState: ImageViewState = .idle
    
    // Form Fields
    var make: String = "Select"
    var model: String = "Select"
    var body: String = "Select"
    var condition: String = "Select"
    var mileage: Double = 500
    var location: String = "Select"
    var selectedYear: String = "Select"
    var price: Double = 500
    var phoneNumber: String = "07"
    var description: String = ""
    var range: String = "Select"
    var colour: String = "Select"
    var publicChargingTime: String = "Select"
    var homeChargingTime: String = "Select"
    var batteryCapacity: String = "Select"
    var powerBhp: String = "Select"
    var regenBraking: String = "Select"
    var warranty: String = "Select"
    var serviceHistory: String = "Select"
    var numberOfOwners: String = "Select"
    var isPromoted: Bool = false
    
    // MARK: - Image Properties
    var selectedImages: [SelectedImage?] = Array(repeating: nil, count: 10)
    var imageSelections: [PhotosPickerItem?] = Array(repeating: nil, count: 10)
    var isLoadingImages: [Bool] = Array(repeating: false, count: 10)
    var imagesURLs: [URL] = []
    var thumbnailsURLs: [URL] = []
    var totalImageCount: Int {
        selectedImages.compactMap({ $0 }).count
    }
    
    // MARK: - DVLA Check
    var registrationNumber: String = ""
    
    // MARK: - Data Arrays
    var loadedModels: [EVModels] = []
    var makeOptions: [String] { ["Select"] + loadedModels.map { $0.make } }
    var modelOptions: [String] = []
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
    @ObservationIgnored @Injected(\.listingService) private var listingService
    @ObservationIgnored @Injected(\.prohibitedWordsService) private var prohibitedWordsService
    @ObservationIgnored @Injected(\.imageManager) private var imageManager
    @ObservationIgnored @Injected(\.dvlaService) private var dvlaService
    @ObservationIgnored @Injected(\.supabaseService) private var supabaseService
    
    // MARK: - Main Actor Functions
    @MainActor
    func loadBulkData() async {
        await loadProhibitedWords()
        await loadModels()
        await loadEVFeatures()
        await loadLocations()
        self.subFormViewState = .loaded
    }
    
    @MainActor
    func createListing() async {
        viewState = .uploading
        self.uploadingProgress = 0.0
        
        do {
            guard let user = try? await supabaseService.client.auth.session.user else {
                viewState = .error(ListingFormViewStateMessages.noAuthUserFound.message)
                return
            }
            
            let fieldsToCheck = [description]
            guard !prohibitedWordsService.containsProhibitedWords(in: fieldsToCheck) else {
                viewState = .error(ListingFormViewStateMessages.inappropriateField.message)
                return
            }
            
            // Calculate the total number of steps (number of images + 1 for the listing creation)
            let nonNilImageItems = selectedImages.compactMap { $0 }
            let totalSteps = nonNilImageItems.count 
            
            try await uploadSelectedImages(for: user.id, totalSteps: totalSteps)
            
            let listingToCreate = Listing(createdAt: Date(), imagesURL: imagesURLs, thumbnailsURL: thumbnailsURLs, make: make, model: model, bodyType: body, condition: condition, mileage: mileage, location: location, yearOfManufacture: selectedYear, price: price, phoneNumber: phoneNumber, textDescription: description, range: range, colour: colour, publicChargingTime: publicChargingTime, homeChargingTime: homeChargingTime, batteryCapacity: batteryCapacity, powerBhp: powerBhp, regenBraking: regenBraking, warranty: warranty, serviceHistory: serviceHistory, numberOfOwners: numberOfOwners, userID: user.id, isPromoted: isPromoted)
            
            try await listingService.createListing(listingToCreate)
            
            resetState()
            viewState = .success(ListingFormViewStateMessages.createSuccess.message)
        } catch {
            self.viewState = .error(ListingFormViewStateMessages.generalError.message)
        }
    }
    
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
            let imageURLString = try await imageManager.uploadImage(image.data, from: bucketName, to: folderPath, targetWidth: 500, targetHeight: 500, compressionQuality: 0.4)
            if let urlString = imageURLString, let url = URL(string: urlString) {
                self.imagesURLs.append(url)
            }
            self.uploadingProgress += 1.5 / Double(totalSteps)
        }
        
        if let firstImageItem = nonNilImageItems.first {
            let thumbnailURLString = try await imageManager.uploadImage(firstImageItem.data, from: bucketName, to: folderPath, targetWidth: 120, targetHeight: 120, compressionQuality: 0.4)
            if let thumbUrlString = thumbnailURLString, let url = URL(string: thumbUrlString) {
                self.thumbnailsURLs.append(url)
            } else {
            }
        }
    }
    
    @MainActor
    func sendDvlaRequest() async {
        viewState = .loading
        do {
            let decodedCar = try await dvlaService.loadDetails(registrationNumber: registrationNumber)
            
            if decodedCar.fuelType.uppercased() == "ELECTRICITY" {
                viewState = .loaded
            } else {
                self.viewState = .error(ListingFormViewStateMessages.notElectric.message)
            }
        } catch {
            self.viewState = .error(ListingFormViewStateMessages.invalidRegistration.message)
        }
    }
    
    @MainActor
    func loadItem(item: PhotosPickerItem, at index: Int) async {
        isLoadingImages[index] = true
        defer { isLoadingImages[index] = false }
        
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
    
    @MainActor
    func resetSubformToLoaded() {
        self.subFormViewState = .loaded
    }
    
    // MARK: - Helpers and misc
    func isFormValid() -> Bool {
        let isValid = make != "Select" &&
        model != "Select" &&
        body != "Select" &&
        condition != "Select" &&
        mileage > 500 &&
        location != "Select" &&
        selectedYear != "Select" &&
        price > 500 &&
        phoneNumber.isValidPhoneNumber &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        range != "Select" &&
        colour != "Select" &&
        publicChargingTime != "Select" &&
        homeChargingTime != "Select" &&
        batteryCapacity != "Select" &&
        powerBhp != "Select" &&
        regenBraking != "Select" &&
        warranty != "Select" &&
        serviceHistory != "Select" &&
        numberOfOwners != "Select" &&
        !selectedImages.compactMap({ $0 }).isEmpty // Ensure at least one image is selected
        
        return isValid
    }
    
    private func loadProhibitedWords() async {
        do {
            try await prohibitedWordsService.loadProhibitedWords()
        } catch {
        }
    }
    
    private func loadLocations() async {
        do {
            let loadedData = try await listingService.loadLocations()
                
            availableLocations = ["Select"] + loadedData.compactMap { $0.city }
        } catch {
            self.subFormViewState = .error(ListingFormViewStateMessages.generalError.message)
        }
    }
    
    private func loadEVFeatures() async {
        do {
            let loadedData = try await listingService.loadEVfeatures()
                            
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
            
        } catch {
            self.subFormViewState = .error(ListingFormViewStateMessages.generalError.message)
        }
    }
    
    private func loadModels() async {
        if loadedModels.isEmpty {
            do {
                self.loadedModels = try await listingService.loadModels()
                
                // Update available models
                updateAvailableModels()
            } catch {
                self.subFormViewState = .error(ListingFormViewStateMessages.generalError.message)
            }
        }
    }
    
    func resetState() {
        registrationNumber = ""
        make = "Select"
        model = "Select"
        body = "Select"
        condition = "Select"
        mileage = 500
        location = "Select"
        selectedYear = "Select"
        price = 500
        phoneNumber = "07"
        description = ""
        range = "Select"
        colour = "Select"
        publicChargingTime = "Select"
        homeChargingTime = "Select"
        batteryCapacity = "Select"
        powerBhp = "Select"
        regenBraking = "Select"
        warranty = "Select"
        serviceHistory = "Select"
        numberOfOwners = "Select"
        isPromoted = false
        selectedImages = Array(repeating: nil, count: 10)
        imageSelections = Array(repeating: nil, count: 10)
        uploadingProgress = 0.0
        imageViewState = .idle
        subFormViewState = .loading
        viewState = .idle
    }
    
    func resetImageStateToIdle() {
        imageViewState = .idle
    }
    
    func deleteImage(id: String) {
        if let index = selectedImages.firstIndex(where: { $0?.id == id }) {
            selectedImages[index] = nil
            imageSelections[index] = nil
        }
    }
            
    func updateAvailableModels() {
        if make == "Select" {
            modelOptions = ["Select"] + loadedModels.flatMap { $0.models }
        } else if let selectedCarMake = loadedModels.first(where: { $0.make == make }) {
            modelOptions = ["Select"] + selectedCarMake.models
        } else {
            modelOptions = ["Select"]
        }
        
        // Check if the current model is still valid in the new list of available models
        if !modelOptions.contains(model) {
            self.model = "Select"
        }
    }
    
    func clearDescription() {
        self.description = ""
    }
    
    func retrieveImages(listing: Listing) async {}
}



