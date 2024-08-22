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
    var selectedYear: String = "Select"
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
    
    var imagesURLs: [URL] = []
    var thumbnailsURLs: [URL] = []
    
    // Pre-selected properties
    var loadedModels: [EVModels] = []
    var availableModels: [String] = []
    var cities: [String] = []
    
    var bodyType: [String] = []
    var yearOfManufacture: [String] = []
    var vehicleCondition: [String] = []
    var vehicleRange: [String] = []
    var homeCharge: [String] = []
    var publicCharge: [String] = []
    var batteryCap: [String] = []
    var vehicleRegenBraking: [String] = []
    var vehiclePowerBhp: [String] = []
    var vehicleWarranty: [String] = []
    var vehicleServiceHistory: [String] = []
    var vehicleNumberOfOwners: [String] = []
    var vehicleColours: [String] = []
    
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
    func loadBulkData() async {
        self.viewState = .loading
        await loadProhibitedWords()
        await loadModels()
        await loadEVFeatures()
        await loadUKcities()
        self.viewState = .loaded
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
            
            let fieldsToCheck = [model, description]
            guard !prohibitedWordsService.containsProhibitedWords(in: fieldsToCheck) else {
                viewState = .error(ListingFormViewStateMessages.inappropriateField.message)
                return
            }
            
            // Calculate the total number of steps (number of images + 1 for the listing creation)
            let nonNilImageItems = selectedImages.compactMap { $0 }
            let totalSteps = nonNilImageItems.count 
            
            try await uploadSelectedImages(for: user.id, totalSteps: totalSteps)
            
            let listingToCreate = Listing(createdAt: Date(), imagesURL: imagesURLs, thumbnailsURL: thumbnailsURLs, make: make, model: model, condition: condition, mileage: mileage, yearOfManufacture: selectedYear, price: price, textDescription: description, range: range, colour: colour, publicChargingTime: publicChargingTime, homeChargingTime: homeChargingTime, batteryCapacity: batteryCapacity, powerBhp: powerBhp, regenBraking: regenBraking, warranty: warranty, serviceHistory: serviceHistory, numberOfOwners: numberOfOwners, userID: user.id)
            
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
            let decodedCar = try await dvlaService.loadDetails(registrationNumber: registrationNumber)
            
            if decodedCar.fuelType.uppercased() == "ELECTRICITY" {
                self.selectedYear = "\(decodedCar.yearOfManufacture)"
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
    
    private func loadProhibitedWords() async {
        do {
            try await prohibitedWordsService.loadProhibitedWords()
        } catch {
            print("Failed to load prohibited words: \(error)")
        }
    }
    
    var totalImageCount: Int {
        selectedImages.compactMap({ $0 }).count
    }
        
    // MARK: - Load Models, Cities and EV specs
    
    private func loadModels() async {
        if loadedModels.isEmpty || availableModels.isEmpty {
            do {
                self.loadedModels = try await listingService.loadModels()
                updateAvailableModels()
                
                print("DEBUG: Fetching make and models")
            } catch {
                print("DEBUG: Failed to fetch car makes and models from Supabase: \(error)")
                self.viewState = .error(ListingFormViewStateMessages.generalError.message)
            }
        }
    }
    
    func updateAvailableModels() {
        if make == "Any" {
            availableModels = loadedModels.flatMap { $0.models }
        } else if let selectedCarMake = loadedModels.first(where: { $0.make == make }) {
            availableModels = selectedCarMake.models
        } else {
            availableModels = []
        }
        
        // Set model to "Any" if it's the default case, or keep the first available model
        if model == "Any" || availableModels.isEmpty {
            self.model = "Any"
        } else {
            self.model = availableModels.first ?? "Any"
        }
    }
    
    private func loadUKcities() async {
        do {
            let fetchedData = try await listingService.loadCities()
                
            // Clear existing data in the arrays to avoid duplicates
            cities.removeAll()
            cities.append("Any")
            
            // Iterate over the fetched data and append to arrays
            for city in fetchedData {
                cities.append(city.city)
            }
        } catch {
            print("DEBUG: Failed to fetch colours: \(error)")
            self.viewState = .error(ListingFormViewStateMessages.generalError.message)
        }
    }
    
    private func loadEVFeatures() async {
        do {
            let fetchedData = try await listingService.loadEVfeatures()
                
            // Clear existing data in the arrays to avoid duplicates
            bodyType.removeAll()
            yearOfManufacture.removeAll()
            vehicleCondition.removeAll()
            vehicleRange.removeAll()
            homeCharge.removeAll()
            publicCharge.removeAll()
            batteryCap.removeAll()
            vehicleRegenBraking.removeAll()
            vehicleWarranty.removeAll()
            vehicleServiceHistory.removeAll()
            vehicleNumberOfOwners.removeAll()
            vehiclePowerBhp.removeAll()
            vehicleColours.removeAll()
            
            bodyType.append("Any")
            yearOfManufacture.append("Any")
            vehicleCondition.append("Any")
            vehicleRange.append("Any")
            homeCharge.append("Any")
            publicCharge.append("Any")
            batteryCap.append("Any")
            vehicleRegenBraking.append("Any")
            vehicleWarranty.append("Any")
            vehicleServiceHistory.append("Any")
            vehicleNumberOfOwners.append("Any")
            vehiclePowerBhp.append("Any")
            vehicleColours.append("Any")
            
            // Iterate over the fetched data and append to arrays
            for evSpecific in fetchedData {
                bodyType.append(contentsOf: evSpecific.bodyType)
                yearOfManufacture.append(contentsOf: evSpecific.yearOfManufacture)
                vehicleCondition.append(contentsOf: evSpecific.condition)
                vehicleRange.append(contentsOf: evSpecific.range)
                homeCharge.append(contentsOf: evSpecific.homeChargingTime)
                publicCharge.append(contentsOf: evSpecific.publicChargingTime)
                batteryCap.append(contentsOf: evSpecific.batteryCapacity)
                vehicleRegenBraking.append(contentsOf: evSpecific.regenBraking)
                vehicleWarranty.append(contentsOf: evSpecific.warranty)
                vehicleServiceHistory.append(contentsOf: evSpecific.serviceHistory)
                vehicleNumberOfOwners.append(contentsOf: evSpecific.owners)
                vehiclePowerBhp.append(contentsOf: evSpecific.powerBhp)
                vehicleColours.append(contentsOf: evSpecific.colours)
            }
        } catch {
            print("DEBUG: Failed to fetch colours: \(error)")
            self.viewState = .error(ListingFormViewStateMessages.generalError.message)
        }
    }
    
    func retrieveImages(listing: Listing) async {}
}



