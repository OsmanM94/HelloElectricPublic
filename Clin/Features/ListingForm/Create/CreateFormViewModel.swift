//
//  UploadViewModel.swift
//  Clin
//
//  Created by asia on 25/06/2024.
//

import SwiftUI
import PhotosUI

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
    var imageViewState: ImageViewState = .idle
    
    var selectedImages: [SelectedImage?] = Array(repeating: nil, count: 10)
    var imageSelections: [PhotosPickerItem?] = Array(repeating: nil, count: 10)
    var isLoading: [Bool] = Array(repeating: false, count: 10)

    private(set) var uploadingProgress: Double = 0.0
    
    ///DVLA checks
    var registrationNumber: String = ""
    
    var make: String = ""
    var model: String = ""
    var condition: String = "Used"
    var mileage: Double = 500
    var yearOfManufacture: String = "2015"
    var price: Double = 500
    var description: String = ""
    var range: String = "300"
    var colour: String = ""
    var publicChargingTime: String = "30mins"
    var homeChargingTime: String = "1hr"
    var batteryCapacity: String = "40kWh"
    var powerBhp: String = "40"
    var regenBraking: String = "Yes"
    var warranty: String = "Yes"
    var serviceHistory: String = "Yes"
    var numberOfOwners: String = "1"
    var isPromoted: Bool = false
    
    var carMakes: [CarMake] = []
    var availableModels: [String] = []
    
    let yearsOfmanufacture: [String] = Array(2010...2030).map { String($0) }
    let vehicleCondition: [String] = ["New", "Used"]
    let vehicleRegenBraking: [String] = ["Yes", "No"]
    let vehicleWarranty: [String] = ["Yes", "No"]
    let vehicleServiceHistory: [String] = ["Yes", "No"]
    let vehicleNumberOfOwners: [String] = ["1", "2", "3", "4+"]
    
    var imagesURLs: [URL] = []
    var thumbnailsURLs: [URL] = []
    
    private let dvlaService = DvlaService()
    
    private let listingService: ListingServiceProtocol
    private let imageManager: ImageManagerProtocol
    private let prohibitedWordsService: ProhibitedWordsServiceProtocol
    
    init(listingService: ListingServiceProtocol, imageManager: ImageManagerProtocol, prohibitedWordsService: ProhibitedWordsServiceProtocol) {
        self.listingService = listingService
        self.imageManager = imageManager
        self.prohibitedWordsService = prohibitedWordsService
    }
    
    @MainActor
    func createListing() async {
        viewState = .uploading
        self.uploadingProgress = 0.0
        
        do {
            guard let user = try? await Supabase.shared.client.auth.session.user else {
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
            let totalSteps = nonNilImageItems.count + 1
            
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
        make = ""
        model = ""
        mileage = 0
        yearOfManufacture = ""
        price = 0
        description = ""
        range = ""
        colour = ""
        publicChargingTime = ""
        homeChargingTime = ""
        batteryCapacity = ""
        powerBhp = ""
        regenBraking = ""
        warranty = ""
        serviceHistory = ""
        numberOfOwners = ""
        selectedImages = Array(repeating: nil, count: 10) 
        imageSelections = Array(repeating: nil, count: 10)
        uploadingProgress = 0.0
        imageViewState = .idle
        viewState = .idle
    }
    
    func resetStateToIdle() {
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
        do {
            self.carMakes = try await listingService.fetchMakeModels()
            
            // Set the initial car make
            self.make = carMakes.first?.make ?? ""
            
            // Update available models based on the fetched car makes
            updateAvailableModels()
        } catch {
            print("DEBUG: Failed to fetch car makes and models from Supabase: \(error)")
            viewState = .error(ListingFormViewStateMessages.generalError.message)
        }
    }
        
    func updateAvailableModels() {
        guard let selectedCarMake = carMakes.first(where: { $0.make == make }) else {
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



