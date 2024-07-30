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
final class ListingFormViewModel {
    enum ViewState {
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
        case deleting
        case loaded
    }
    
    var viewState: ViewState = .idle
    var imageLoadingState: ImageLoadingState = .idle
    
    var pickedImages: [PickedImage] = []
    var imageSelections: [PhotosPickerItem] = []
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
    
    private let dvlaService = DvlaService()
    
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
            guard let user = try? await SupabaseService.shared.client.auth.session.user else {
                viewState = .error(ListingFormViewStateMessages.noAuthUserFound.message)
                return
            }
            
            let fieldsToCheck = [model, description]
            guard !ProhibitedWordsService.shared.containsProhibitedWords(in: fieldsToCheck) else {
                viewState = .error(ListingFormViewStateMessages.inappropriateField.message)
                return
            }
            
            var imagesURLs: [URL] = []
            
            for image in pickedImages {
                let folderPath = "\(user.id)"
                let bucketName = "car_images"
                
                let imageURLString = try await ImageManager.shared.uploadImage(image.data, from: bucketName, to: folderPath, compressionQuality: 0.5)
                if let urlString = imageURLString, let url = URL(string: urlString) {
                    imagesURLs.append(url)
                }
                uploadingProgress += 1.0 / Double(pickedImages.count)
            }
            
            try await ListingService.shared.createListing(
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
            viewState = .success(ListingFormViewStateMessages.createSuccess.message)
        } catch {
            self.viewState = .error(ListingFormViewStateMessages.generalError.message)
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
        pickedImages = []
        imageSelections = []
        showDeleteAlert = false
        imageToDelete = nil
        uploadingProgress = 0.0
        imageLoadingState = .idle
        viewState = .idle
    }
    
    @MainActor
    func loadItem(item: PhotosPickerItem) async {
        imageLoadingState = .loading
        
        if let pickedImage = await ImageManager.shared.loadItem(item: item) {
            pickedImages.append(pickedImage)
         
            imageLoadingState = .loaded
        } else {
            viewState = .error(ListingFormViewStateMessages.sensitiveContent.message)
        }
    }
    
    @MainActor
    func checkImageState() {
        if pickedImages.isEmpty {
            imageLoadingState = .idle
        }
    }
    
    @MainActor
    func deleteImage(_ image: PickedImage) async {
        imageLoadingState = .deleting
        if let index = pickedImages.firstIndex(of: image) {
            pickedImages.remove(at: index)
            imageSelections.remove(at: index)
        }
        checkImageState()
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func loadProhibitedWords() async {
        do {
            try await ProhibitedWordsService.shared.loadProhibitedWords()
        } catch {
            print("Failed to load prohibited words: \(error)")
        }
    }
    
}
