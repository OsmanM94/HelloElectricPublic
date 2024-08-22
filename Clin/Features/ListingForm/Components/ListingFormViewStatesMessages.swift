//
//  ListingFormViewStatesMessages.swift
//  Clin
//
//  Created by asia on 29/07/2024.
//

import Foundation

enum ListingFormViewStateMessages: String, Error {
    case inappropriateField = "One of the fields contains prohibited words."
    case sensitiveContent = "The selected image contains sensitive content. Please choose a different image."
    case sensitiveApiNotEnabled = "Please enable Sensitive Content Warning, Go to Settings > Privacy & Security > Sensitive Content Warning."
    case generalError = "An error occurred. Please try again."
    case noAuthUserFound = "No authenticated user found."
    case updateSuccess = "Listing updated successfully."
    case createSuccess = "Listing created successfully."
    case notElectric = "Your vehicle is not electric."
    case invalidRegistration = "Invalid registration number."
    case errorDownloadingImages = "Error retrieving images from server, Please try again."
    
    var message: String {
        return self.rawValue
    }
}
