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
final class ListingFormEditViewModel {
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
   }
    
    var formEditViewState: ViewState = .idle
    var imageLoadingState: ImageLoadingState = .idle
    
    var pickedImages: [PickedImage] = []
    var imageSelections: [PhotosPickerItem] = []

    var showDeleteAlert: Bool = false
    var imageToDelete: PickedImage?
    var uploadingProgress: Double = 0.0
    
    let yearsOfmanufacture: [String] = Array(2010...2030).map { String($0) }
    let vehicleCondition: [String] = ["New", "Used"]
    let vehicleRegenBraking: [String] = ["Yes", "No"]
    let vehicleWarranty: [String] = ["Yes", "No"]
    let vehicleServiceHistory: [String] = ["Yes", "No"]
    let vehicleNumberOfOwners: [String] = ["1", "2", "3", "4+"]
    
    @MainActor
    func updateUserListing(_ listing: Listing) async {
        formEditViewState = .uploading
        uploadingProgress = 0.0
        do {
            guard let user = try? await SupabaseService.shared.client.auth.session.user else {
                formEditViewState = .error("No authenticated user found.")
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
            
            try await ListingService.shared.updateListing(
                listing,
                imagesURL: imagesURLs,
                make: listing.make,
                model: listing.model,
                condition: listing.condition,
                mileage: listing.mileage,
                yearOfManufacture: listing.yearOfManufacture,
                price: listing.price,
                description: listing.description,
                range: listing.range,
                colour: listing.colour,
                publicChargingTime: listing.publicChargingTime,
                homeChargingTime: listing.homeChargingTime,
                batteryCapacity: listing.batteryCapacity,
                powerBhp: listing.powerBhp,
                regenBraking: listing.regenBraking,
                warranty: listing.warranty,
                serviceHistory: listing.serviceHistory,
                numberOfOwners: listing.numberOfOwners,
                userID: listing.userID
            )
            
            formEditViewState = .success("Listing updated successfully.")
            print("Listing updated succesfully.")
        } catch {
            formEditViewState = .error("Error updating the listing, please try again.")
        }
    }
    
    @MainActor
    func deleteUserListing(_ listing: Listing) async {
        formEditViewState = .loading
        do {
            guard let id = listing.id else {
                formEditViewState = .error("No authenticated user found.")
                return
            }
            
            try await ListingService.shared.deleteListing(at: id)
            formEditViewState = .success("Listing deleted successfully.")
            print("Listing deleted succesfully")
        } catch {
            formEditViewState = .error("Error deleting listing, please try again.")
        }
    }
    
    func resetState() {
        pickedImages = []
        imageSelections = []
        showDeleteAlert = false
        imageToDelete = nil
        uploadingProgress = 0.0
        imageLoadingState = .idle
        formEditViewState = .idle
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
        let analysisResult = await ImageManager.shared.analyzeImage(data)
        
        switch analysisResult {
        case .isSensitive:
            formEditViewState = .error("One or more images contains sensitive content.")
            return false
        case .error(let message):
            formEditViewState = .error(message)
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
