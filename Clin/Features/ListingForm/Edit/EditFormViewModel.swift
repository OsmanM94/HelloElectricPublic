//
//  ListingFormEditViewModel.swift
//  Clin
//
//  Created by asia on 27/07/2024.
//

import Foundation
import SwiftUI
import PhotosUI


@Observable
final class EditFormViewModel {
    enum ViewState {
        case idle
        case loading
        case uploading
        case success(String)
        case error(String)
    }
    
    enum ImageViewState {
       case idle
       case loading
       case loaded
       case deleting
   }
    
    var viewState: ViewState = .idle
    var imageViewState: ImageViewState = .idle
    
    var pickedImages: [PickedImage] = []
    var imageSelections: [PhotosPickerItem] = []
    var savedImageIdentifiers: [String] = []
    
    var showDeleteAlert: Bool = false
    var imageToDelete: PickedImage?
    var uploadingProgress: Double = 0.0
    var imagesURLs: [URL] = []
    var thumbnailsURLs: [URL] = []
    
    let yearsOfmanufacture: [String] = Array(2010...2030).map { String($0) }
    let vehicleCondition: [String] = ["New", "Used"]
    let vehicleRegenBraking: [String] = ["Yes", "No"]
    let vehicleWarranty: [String] = ["Yes", "No"]
    let vehicleServiceHistory: [String] = ["Yes", "No"]
    let vehicleNumberOfOwners: [String] = ["1", "2", "3", "4+"]
    
    private let listingService: ListingServiceProtocol
    
    init(listingService: ListingServiceProtocol) {
        self.listingService = listingService
    }
    
    @MainActor
    func updateUserListing(_ listing: Listing) async {
        viewState = .uploading
        uploadingProgress = 0.0
        do {
            guard let user = try? await Supabase.shared.client.auth.session.user else {
                viewState = .error(ListingFormViewStateMessages.noAuthUserFound.message)
                return
            }
            
            let fieldsToCheck = [listing.model, listing.textDescription]
            guard !ProhibitedWordsService.shared.containsProhibitedWords(in: fieldsToCheck) else {
                viewState = .error(ListingFormViewStateMessages.inappropriateField.message)
                return
            }
            
            try await uploadPickedImages(for: user.id)
            
            let listingToUpdate = Listing(id: listing.id, createdAt: Date(), imagesURL: imagesURLs, thumbnailsURL: thumbnailsURLs, make: listing.make, model: listing.model, condition: listing.condition, mileage: listing.mileage, yearOfManufacture: listing.yearOfManufacture, price: listing.price, textDescription: listing.textDescription, range: listing.range, colour: listing.colour, publicChargingTime: listing.publicChargingTime, homeChargingTime: listing.homeChargingTime, batteryCapacity: listing.batteryCapacity, powerBhp: listing.powerBhp, regenBraking: listing.regenBraking, warranty: listing.warranty, serviceHistory: listing.serviceHistory, numberOfOwners: listing.numberOfOwners, userID: listing.userID)
           
            try await listingService.updateListing(listingToUpdate)
            
            viewState = .success(ListingFormViewStateMessages.updateSuccess.message)
        } catch {
            viewState = .error(ListingFormViewStateMessages.generalError.message)
        }
    }
    
    @MainActor
    private func uploadPickedImages(for userId: UUID) async throws {
        imagesURLs.removeAll()
        thumbnailsURLs.removeAll()
        
        guard !pickedImages.isEmpty else {
            return
        }
        
        let folderPath = "\(userId)"
        let bucketName = "car_images"
        
        for image in pickedImages {
            let imageURLString = try await ImageManager.shared.uploadImage(image.data, from: bucketName, to: folderPath, targetWidth: 350, targetHeight: 350, compressionQuality: 1.0)
            if let urlString = imageURLString, let url = URL(string: urlString) {
                self.imagesURLs.append(url)
            }
            self.uploadingProgress += 1.0 / Double(pickedImages.count)
        }
        
        if let firstImage = pickedImages.first {
            let thumbnailURLString = try await ImageManager.shared.uploadImage(firstImage.data, from: bucketName, to: folderPath, targetWidth: 120, targetHeight: 120, compressionQuality: 0.4)
            if let thumbUrlString = thumbnailURLString, let url = URL(string: thumbUrlString) {
                self.thumbnailsURLs.append(url)
            }
        }
    }
       
    func resetState() {
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
            print("DEBUG: Failed to load prohibited words: \(error)")
        }
    }
    
    var totalImageCount: Int {
        imageSelections.count
    }
}
