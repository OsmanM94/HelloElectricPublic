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
        case uploading
        case loaded
        case success(String)
        case error(String)
    }
    
    enum ImageLoadingState {
        case idle
        case loading
        case loaded
    }
        
    var viewState: CreateListingViewState = .idle
    var imageLoadingState: ImageLoadingState = .idle
    
    var pickedImages: [PickedImage] = []
    var imageSelections: [PhotosPickerItem] = [] 
    var isLoadingImages: Bool = false
    var showDeleteAlert: Bool = false
    var imageToDelete: PickedImage?
    var uploadingProgress: Double = 0.0
    
    ///DVLA checks
    var registrationNumber: String = ""
    
    var make: String = ""
    var model: String = ""
    var condition: String = "Used"
    var mileage: Double = 0.0
    var yearOfManufacture: String = "2015"
    var price: Double = 0.0
    var description: String = ""
    var range: String = ""
    var colour: String = ""
    var publicChargingTime: String = ""
    var homeChargingTime: String = ""
    var batteryCapacity: String = ""
    var powerBhp: String = ""
    var regenBraking: String = "Yes"
    var warranty: String = "Yes"
    var serviceHistory: String = "Yes"
    var numberOfOwners: String = "1"
    var isPromoted: Bool = false
    
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
        viewState = .uploading
        uploadingProgress = 0.0
        do {
            guard let user = try? await supabase.auth.session.user else {
                print("No authenticated user found")
                return
            }
            
            guard !containsProhibitedWordsInInputs() else {
                return
            }
            
            var imagesURLs: [URL] = []
            
            for image in pickedImages {
                let folderPath = "\(user.id)"
                let bucketName = "car_images"
                
                let imageURLString = try await imageService.uploadImage(image.data, from: bucketName, to: folderPath, compressionQuality: 0.5)
                if let urlString = imageURLString, let url = URL(string: urlString) {
                    imagesURLs.append(url)
                }
                uploadingProgress += 1.0 / Double(pickedImages.count)
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
            self.viewState = .error("Error creating listing, Please try again.")
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
        pickedImages = []
        imageSelections = []
        isLoadingImages = false
        showDeleteAlert = false
        imageToDelete = nil
        uploadingProgress = 0.0
        imageLoadingState = .idle
        viewState = .idle
    }

    @MainActor
    func loadItem(item: PhotosPickerItem) async {
        imageLoadingState = .loading
        do {
            let data = try await item.loadTransferable(type: Data.self)
            guard let data = data else { return }

            guard let _ = UIImage(data: data) else { return }

            if await analyzeImage(data) {
                guard let pickedImage = PickedImage(data: data) else { return  }
                self.pickedImages.append(pickedImage)
            }
            
            print("Images loaded and analyzed from PhotosPicker")
            imageLoadingState = .loaded
        } catch {
            print("Error loading image: \(error.localizedDescription)")
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
    
    @MainActor
    func checkImageState() {
        if pickedImages.isEmpty {
            imageLoadingState = .idle
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
    
    @MainActor
    func deleteImage(_ image: PickedImage) async {
        if let index = pickedImages.firstIndex(of: image) {
            pickedImages.remove(at: index)
            imageSelections.remove(at: index)
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
