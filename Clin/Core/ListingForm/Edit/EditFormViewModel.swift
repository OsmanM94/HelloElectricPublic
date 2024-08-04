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
    
    enum ImageLoadingState {
       case idle
       case loading
       case loaded
       case deleting
   }
    
    var viewState: ViewState = .idle
    var imageLoadingState: ImageLoadingState = .idle
    
    var pickedImages: [PickedImage] = []
    var imageSelections: [PhotosPickerItem] = []

    var showDeleteAlert: Bool = false
    var imageToDelete: PickedImage?
    var uploadingProgress: Double = 0.0
    var imagesURLs: [URL] = []
    
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
            
            let listingToUpdate = Listing(id: listing.id, createdAt: Date(), imagesURL: imagesURLs, make: listing.make, model: listing.model, condition: listing.condition, mileage: listing.mileage, yearOfManufacture: listing.yearOfManufacture, price: listing.price, textDescription: listing.textDescription, range: listing.range, colour: listing.colour, publicChargingTime: listing.publicChargingTime, homeChargingTime: listing.homeChargingTime, batteryCapacity: listing.batteryCapacity, powerBhp: listing.powerBhp, regenBraking: listing.regenBraking, warranty: listing.warranty, serviceHistory: listing.serviceHistory, numberOfOwners: listing.numberOfOwners, userID: listing.userID)
           
            try await listingService.updateListing(listingToUpdate)
            
            viewState = .success(ListingFormViewStateMessages.updateSuccess.message)
            print("Listing updated succesfully.")
        } catch {
            viewState = .error(ListingFormViewStateMessages.generalError.message)
        }
    }
    
    @MainActor
    private func uploadPickedImages(for userId: UUID) async throws {
        imagesURLs.removeAll()
        for image in pickedImages {
            let folderPath = "\(userId)"
            let bucketName = "car_images"
            
            let imageURLString = try await ImageManager.shared.uploadImage(image.data, from: bucketName, to: folderPath, compressionQuality: 0.5)
            
            if let urlString = imageURLString, let url = URL(string: urlString) {
                self.imagesURLs.append(url)
            }
            self.uploadingProgress += 1.0 / Double(pickedImages.count)
        }
    }
       
    func resetState() {
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
    
    var totalImageCount: Int {
        imageSelections.count
    }
    
}




/// IN REVIEW
///
/// //    @MainActor
//    func loadImagesFromListing(_ listing: Listing) async {
//        imageLoadingState = .loading
//        pickedImages = []
//
//        for imageURL in listing.imagesURL {
//            do {
//                let (data, _) = try await URLSession.shared.data(from: imageURL)
//                guard let pickedImage = PickedImage(data: data) else { return }
//                pickedImages.append(pickedImage)
//            } catch {
//                viewState = .error("Failed to load images.")
//                return
//            }
//        }
//        imageLoadingState = .loaded
//    }
