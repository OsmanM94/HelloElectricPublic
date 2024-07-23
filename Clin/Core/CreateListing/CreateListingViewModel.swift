//
//  UploadViewModel.swift
//  Clin
//
//  Created by asia on 25/06/2024.
//

import Foundation
import PhotosUI
import SwiftUI

@Observable
final class CreateListingViewModel {
    enum CreateListingViewState {
        case idle
        case loading
        case loaded
        case success(String)
        case error(String)
    }
    
    enum ImageLoadingState {
        case idle
        case loading
        case loaded
    }
    
    var viewState: CreateListingViewState = .loaded
    var imageLoadingState: ImageLoadingState = .idle
    var listingImages: [AvatarImage] = []
    var imageSelections: [PhotosPickerItem] = []
    var isLoadingImages: Bool = false
    var showDeleteAlert: Bool = false
    var imageToDelete: AvatarImage?
    
    var make: String = ""
    var model: String = ""
    var condition: String = "Used"
    var mileage: Double = 0.0
    var yearOfManufacture: String = "2015"
    var price: Double = 0.0
    var description: String = ""
    var range: String = ""
    var colour: String = ""
    var isPromoted: Bool = false
    var publicChargingTime: String = ""
    var homeChargingTime: String = ""
    var batteryCapacity: String = ""
    var powerBhp: String = ""
    var regenBraking: String = "Yes"
    var warranty: String = "Yes"
    var serviceHistory: String = "Yes"
    var numberOfOwners: String = "1"
    
    ///DVLA checks
    var registrationNumber: String = ""
    
    private let carListingService = ListingService.shared
    private let dvlaService = DvlaService()
    private let supabase = SupabaseService.shared.client
    private let imageService = ImageManager.shared
    private let prohibitedWordsService = ProhibitedWordsService.shared
    
    let yearsOfmanufacture: [String] = Array(2010...2030).map { String($0) }
    let vehicleCondition: [String] = ["New", "Used"]
    let vehicleRegenBraking: [String] = ["Yes", "No"]
    let vehicleWarranty: [String] = ["Yes", "No"]
    let vehicleServiceHistory: [String] = ["Yes", "No"]
    let vehicleNumberOfOwners: [String] = ["1", "2", "3", "4+"]
    
    @MainActor
    func createListing() async {
        viewState = .loading
        
        do {
            guard let user = try? await supabase.auth.session.user else {
                print("No authenticated user found")
                return
            }
            
            guard !containsProhibitedWordsInInputs() else {
                return
            }
            
            var imagesURLs: [URL] = []
            for image in listingImages {
                let imageURLString = try await imageService.uploadImage(image.data, to: "car_images", compressionQuality: 0.8)
                if let urlString = imageURLString, let url = URL(string: urlString) {
                    imagesURLs.append(url)
                }
            }
            
            if imagesURLs.isEmpty {
                viewState = .error("Error creating listing.")
                return
            }
            
            try await carListingService.createListing(
                imagesURL: imagesURLs,
                make: make,
                model: model,
                condition: condition,
                mileage: mileage,
                yearOfManufacture: yearOfManufacture,
                price: price,
                description: description,
                range: range,
                colour: colour,
                publicChargingTime: publicChargingTime,
                homeChargingTime: homeChargingTime,
                batteryCapacity: batteryCapacity,
                powerBhp: powerBhp,
                regenBraking: regenBraking,
                warranty: warranty,
                serviceHistory: serviceHistory,
                numberOfOwners: numberOfOwners,
                userID: user.id
            )
            
            resetState()
            viewState = .success("Listing created successfully.")
        } catch {
            self.viewState = .error("Error creating listing.")
            print(error)
        }
    }
    
    @MainActor
    func sendDvlaRequest() async {
        viewState = .loading
        do {
            let decodedCar = try await dvlaService.fetchCarDetails(registrationNumber: registrationNumber)
            
            if decodedCar.fuelType.uppercased() == "ELECTRICITY" {
                self.make = decodedCar.make
                self.yearOfManufacture = "\(decodedCar.yearOfManufacture)"
                self.colour = decodedCar.colour
                viewState = .loaded
            } else {
                self.viewState = .error("Your vehicle is not electric.")
            }
        } catch {
            self.viewState = .error("Invalid registration number.")
            print(error)
        }
    }
    
    func resetState() {
        registrationNumber = ""
        make = ""
        model = ""
        yearOfManufacture = ""
        colour = ""
        price = 0
        mileage = 0
        numberOfOwners = ""
        listingImages = []
        imageSelections = []
        viewState = .idle
    }

    func loadTransferable(from imageSelections: [PhotosPickerItem]) {
        imageLoadingState = .loading
        Task {
            do {
                listingImages = try await withThrowingTaskGroup(of: AvatarImage?.self) { group in
                    for selection in imageSelections {
                        group.addTask {
                            let avatarImage = try await selection.loadTransferable(type: AvatarImage.self)
                            if let data = avatarImage?.data, await self.analyzeImage(data) {
                                return avatarImage
                            }
                            return nil
                        }
                    }
                    return try await group.reduce(into: [AvatarImage]()) { result, image in
                        if let image = image {
                            result.append(image)
                        }
                    }
                }
                print("Images loaded and analyzed from PhotosPicker")
                imageLoadingState = .loaded
            } catch {
                debugPrint(error)
            }
        }
    }
    
    @MainActor
    private func analyzeImage(_ data: Data) async -> Bool {
        let analysisResult = await imageService.analyzeImage(data)
        
        switch analysisResult {
        case .isSensitive:
            viewState = .error("One or more images contains sensitive content.")
            return false
        case .error(let message):
            viewState = .error(message)
            return false
        case .notSensitive:
            return true
        case .analyzing, .notStarted:
            return false
        }
    }
    
    private func containsProhibitedWordsInInputs() -> Bool {
        let fieldsToCheck = [model, description]
        
        for field in fieldsToCheck {
            if containsProhibitedWords(field) {
                viewState = .error("The field '\(field)' contains prohibited words.")
                return true
            }
        }
        return false
    }
    
    private func containsProhibitedWords(_ text: String) -> Bool {
        return prohibitedWordsService.containsProhibitedWords(text)
    }
    
    func deleteImage(_ image: AvatarImage) {
        if let index = listingImages.firstIndex(of: image) {
            listingImages.remove(at: index)
            imageSelections.remove(at: index)
        }
    }
}
