//
//  ListingFormViewStatesMessages.swift
//  Clin
//
//  Created by asia on 29/07/2024.
//

import Foundation

enum ListingFormViewStateMessages: String, Error {
    case inappropriateField = "One of the fields contains prohibited words."
    case sensitiveContent = "Image contains sensitive content or there was an error analyzing the image."
    case generalError = "An error occurred. Please try again."
    case noAuthUserFound = "No authenticated user found."
    case updateSuccess = "Listing updated successfully."
    case createSuccess = "Listing created successfully."
    case notElectric = "Your vehicle is not electric."
    case invalidRegistration = "Invalid registration number."
    
    var message: String {
        return self.rawValue
    }
}
