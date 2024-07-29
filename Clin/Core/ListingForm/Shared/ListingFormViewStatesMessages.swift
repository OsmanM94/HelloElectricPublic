//
//  ListingFormViewStatesMessages.swift
//  Clin
//
//  Created by asia on 29/07/2024.
//

import Foundation

enum ListingFormViewStateMessages: String, Error {
    case inappropriateField = "One of the fields contains prohibited words."
    case sensitiveContent = "One or more images contains sensitive content."
    case generalError = "An error occurred. Please try again."
    case noAuthUserFound = "No authenticated user found."
    case updateSuccess = "Listing updated successfully."
    case createSucess = "Listing created successfully."
    case deleteSuccess = "Listing deleted successfully."
    case deleteError = "Error deleting listing, please try again."
    case notElectric = "Your vehicle is not electric."
    case invalidRegistration = "Invalid registration number."
    
    var message: String {
        return self.rawValue
    }
}
