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
final class CreateFormViewModel {
   
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
    private(set) var subFormViewState: SubFormViewState = .loading

    // MARK: - DVLA Check
    var registrationNumber: String = ""
    
    // MARK: - Dependencies
    // Services
    @ObservationIgnored @Injected(\.listingService) private var listingService
    @ObservationIgnored @Injected(\.dvlaService) private var dvlaService
    @ObservationIgnored @Injected(\.supabaseService) private var supabaseService
    // ViewModels
    @ObservationIgnored @Injected(\.createFormDataModel) var formData
    @ObservationIgnored @Injected(\.createFormImageManager) var imageManager
    @ObservationIgnored @Injected(\.createFormDataLoader) var dataLoader
    @ObservationIgnored @Injected(\.locationManager) var locationManager
    
    @MainActor
    func updateLocation() {
        if let location = locationManager.userLocation {
            formData.latitude = location.latitude
            formData.longitude = location.longitude
        }
    }
    
    // MARK: - Main Actor Methods
    @MainActor
    func loadBulkData() async {
        do {
            try await dataLoader.loadBulkData()
            self.subFormViewState = .loaded
        } catch {
            self.subFormViewState = .error(AppError.ErrorType.generalError.message)
        }
    }
    
    @MainActor
    func createListing() async {
        guard isFormValid() else {
            viewState = .error(AppError.ErrorType.formInvalid.message)
            return
        }
        guard await validateTextDescription() else { return }
        
        viewState = .uploading
        
        do {
            guard let user = try? await supabaseService.client.auth.session.user else {
                viewState = .error(AppError.ErrorType.noAuthUserFound.message)
                return
            }
            
            try await imageManager.uploadSelectedImages(for: supabaseService.client.auth.session.user.id)
            let listing = buildListing(userID: user.id)
            try await listingService.createListing(listing)
            
            resetFormDataAndState()
            viewState = .success(AppError.ErrorType.createSuccess.message)
        } catch {
            print("Error creating listing \(error)")
            viewState = .error(AppError.ErrorType.generalError.message)
        }
    }
    
    @MainActor
    func sendDvlaRequest() async {
        viewState = .loading
        do {
            let decodedCar = try await dvlaService.loadDetails(registrationNumber: registrationNumber)
            viewState = decodedCar.fuelType.uppercased() == "ELECTRICITY" ? .loaded : .error(AppError.ErrorType.notElectric.message)
        } catch {
            viewState = .error(AppError.ErrorType.invalidRegistration.message)
        }
    }
    
    // MARK: - Methods
    func isFormValid() -> Bool {
        return formData.isFormValid() && imageManager.hasValidImageSelection()
    }
    
    func resetFormDataAndState() {
        formData.resetState()
        imageManager.resetState()
        registrationNumber = ""
        viewState = .idle
        subFormViewState = .loading
    }
    
    func updateAvailableModels() {
        formData.model = dataLoader.updateAvailableModels(make: formData.make, currentModel: formData.model)
    }
    
    // MARK: - Private Methods
    private func validateTextDescription() async -> Bool {
        let fieldsToCheck = formData.description
        guard !dataLoader.prohibitedWordsService.containsProhibitedWord(fieldsToCheck) else {
            viewState = .error(AppError.ErrorType.inappropriateField.message)
            return false
        }
        return true
    }
    
    private func buildListing(userID: UUID) -> Listing {
        
        let userLocation = locationManager.userLocation
        
        return Listing(
            createdAt: Date(),
            imagesURL: imageManager.imagesURLs,
            thumbnailsURL: imageManager.thumbnailsURLs,
            make: formData.make,
            model: formData.model,
            bodyType: formData.body,
            condition: formData.condition,
            mileage: formData.mileage,
            location: formData.location,
            yearOfManufacture: formData.selectedYear,
            price: formData.price,
            phoneNumber: formData.phoneNumber,
            textDescription: formData.description,
            range: formData.range,
            colour: formData.colour,
            publicChargingTime: formData.publicChargingTime,
            homeChargingTime: formData.homeChargingTime,
            batteryCapacity: formData.batteryCapacity,
            powerBhp: formData.powerBhp,
            regenBraking: formData.regenBraking,
            warranty: formData.warranty,
            serviceHistory: formData.serviceHistory,
            numberOfOwners: formData.numberOfOwners,
            userID: userID,
            isPromoted: formData.isPromoted,
            latitude: userLocation?.latitude,
            longitude: userLocation?.longitude
        )
    }
}

@Observable
final class CreateFormDataModel {
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
    var latitude: Double?
    var longitude: Double?
    
    func resetState() {
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
    }
    
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
        numberOfOwners != "Select"
        return isValid
    }
    
    func clearDescription() {
        self.description = ""
    }
}

@Observable
final class CreateFormImageManager: ImagePickerProtocol {
    // MARK: - Image properties
    var selectedImages: [SelectedImage?] = Array(repeating: nil, count: 10)
    var imageSelections: [PhotosPickerItem?] = Array(repeating: nil, count: 10)
    var isLoadingImages: [Bool] = Array(repeating: false, count: 10)
    var imagesURLs: [URL] = []
    var thumbnailsURLs: [URL] = []
    private(set) var uploadingProgress: Double = 0.0
    
    // MARK: - Dependencies
    @ObservationIgnored @Injected(\.imageManager) var imageManager
    
    var imageViewState: ImageViewState = .idle
    
    var totalImageCount: Int {
        selectedImages.compactMap { $0 }.count
    }
    
    // MARK: - Methods
    
    func resetState() {
        selectedImages = Array(repeating: nil, count: 10)
        imageSelections = Array(repeating: nil, count: 10)
        imagesURLs.removeAll()
        thumbnailsURLs.removeAll()
        uploadingProgress = 0.0
        imageViewState = .idle
    }
    
    func resetImageStateToIdle() {
        imageViewState = .idle
    }
    
    func hasValidImageSelection() -> Bool {
        return !selectedImages.compactMap({ $0 }).isEmpty // Ensure at least one image is selected
    }
    
    func uploadSelectedImages(for userId: UUID) async throws {
        imagesURLs.removeAll()
        thumbnailsURLs.removeAll()
        uploadingProgress = 0.0
        
        let nonNilImageItems = selectedImages.compactMap { $0 }
        
        guard !nonNilImageItems.isEmpty else { return }
        
        let folderPath = "\(userId)"
        let bucketName = "car_images"
        
        for image in nonNilImageItems {
            let imageURLString = try await imageManager.uploadImage(image.data, from: bucketName, to: folderPath, targetWidth: 500, targetHeight: 500, compressionQuality: 0.8)
            if let urlString = imageURLString, let url = URL(string: urlString) {
                self.imagesURLs.append(url)
            }
            self.uploadingProgress += 1.5 / Double(nonNilImageItems.count)
        }
        
        if let firstImageItem = nonNilImageItems.first {
            let thumbnailURLString = try await imageManager.uploadImage(firstImageItem.data, from: bucketName, to: folderPath, targetWidth: 130, targetHeight: 130, compressionQuality: 0.6)
            if let thumbUrlString = thumbnailURLString, let url = URL(string: thumbUrlString) {
                self.thumbnailsURLs.append(url)
            }
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
            imageViewState = .error(AppError.ErrorType.sensitiveContent.message)
        case .analysisError:
            imageViewState = .sensitiveApiNotEnabled
        case .loadingError:
            imageViewState = .error(AppError.ErrorType.generalError.message)
        }
    }
    
    func deleteImage(id: String) {
        if let index = selectedImages.firstIndex(where: { $0?.id == id }) {
            selectedImages[index] = nil
            imageSelections[index] = nil
        }
    }
    
    func retrieveImages(listing: Listing, id: Int) async throws {}
}

@Observable
final class CreateFormDataLoader {
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
    @ObservationIgnored @Injected(\.prohibitedWordsService) var prohibitedWordsService
    
    // MARK: - Methods
    func loadBulkData() async throws {
        try await loadProhibitedWords()
        try await loadModels()
        try await loadFeatures()
        try await loadLocations()
    }
    
    func updateAvailableModels(make: String, currentModel: String) -> String {
        if make == "Select" {
            modelOptions = ["Select"] + loadedModels.flatMap { $0.models }
        } else if let selectedCarMake = loadedModels.first(where: { $0.make == make }) {
            modelOptions = ["Select"] + selectedCarMake.models
        } else {
            modelOptions = ["Select"]
        }
        
        return modelOptions.contains(currentModel) ? currentModel : "Select"
    }

    // MARK: - Private Methods
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
    
    private func loadModels() async throws {
        if loadedModels.isEmpty {
            loadedModels = try await listingService.loadModels()
        }
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

