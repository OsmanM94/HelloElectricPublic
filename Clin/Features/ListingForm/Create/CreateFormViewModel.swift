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
final class CreateFormViewModel {
    enum ViewState {
        case idle
        case loading
        case uploading
        case loaded
        case success(String)
        case error(String)
    }
    
    enum ImageViewState {
        case idle
        case loading
        case deleting
        case loaded
    }
    
    var viewState: ViewState = .idle
    var imageViewState: ImageViewState = .idle
    
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
    
    let yearsOfmanufacture: [String] = Array(2010...2030).map { String($0) }
    let vehicleCondition: [String] = ["New", "Used"]
    let vehicleRegenBraking: [String] = ["Yes", "No"]
    let vehicleWarranty: [String] = ["Yes", "No"]
    let vehicleServiceHistory: [String] = ["Yes", "No"]
    let vehicleNumberOfOwners: [String] = ["1", "2", "3", "4+"]
    
    var imagesURLs: [URL] = []
    
    private let dvlaService = DvlaService()
    private let listingService: ListingServiceProtocol
    
    init(listingService: ListingServiceProtocol) {
        self.listingService = listingService
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
            guard !ProhibitedWordsService.shared.containsProhibitedWords(in: fieldsToCheck) else {
                viewState = .error(ListingFormViewStateMessages.inappropriateField.message)
                return
            }
            
            try await uploadPickedImages(for: user.id)
        
            let listingToCreate = Listing(createdAt: Date(), imagesURL: imagesURLs, make: make, model: model, condition: condition, mileage: mileage, yearOfManufacture: yearOfManufacture, price: price, textDescription: description, range: range, colour: colour, publicChargingTime: publicChargingTime, homeChargingTime: homeChargingTime, batteryCapacity: batteryCapacity, powerBhp: powerBhp, regenBraking: regenBraking, warranty: warranty, serviceHistory: serviceHistory, numberOfOwners: numberOfOwners, userID: user.id)
            
            try await listingService.createListing(listingToCreate)
            
            resetState()
            viewState = .success(ListingFormViewStateMessages.createSuccess.message)
        } catch {
            self.viewState = .error(ListingFormViewStateMessages.generalError.message)
            print(error)
        }
    }
        
    @MainActor
    private func uploadPickedImages(for userId: UUID) async throws {
        imagesURLs.removeAll()
        for image in pickedImages {
            let folderPath = "\(userId)"
            let bucketName = "car_images"
            
            let imageURLString = try await ImageManager.shared.uploadImage(image.data, from: bucketName, to: folderPath, targetWidth: 120, targetHeight: 120, compressionQuality: 0.5)
        
            if let urlString = imageURLString, let url = URL(string: urlString) {
                self.imagesURLs.append(url)
            }
            self.uploadingProgress += 1.0 / Double(pickedImages.count)
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
        imageViewState = .idle
        viewState = .idle
    }
    
    @MainActor
    func loadItem(item: PhotosPickerItem) async {
        imageViewState = .loading
        
        if let pickedImage = await ImageManager.shared.loadItem(item: item) {
            pickedImages.append(pickedImage)
            imageViewState = .loaded
        } else {
            viewState = .error(ListingFormViewStateMessages.sensitiveContent.message)
        }
    }
    
    @MainActor
    func checkImageState() {
        if pickedImages.isEmpty {
            imageViewState = .idle
        }
    }
    
    @MainActor
    func deleteImage(_ image: PickedImage) async {
        imageViewState = .deleting
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

