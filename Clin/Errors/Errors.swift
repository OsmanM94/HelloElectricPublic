//
//  Errors.swift
//  Clin
//
//  Created by asia on 10/09/2024.
//

import Foundation


enum AppError: Error, LocalizedError {
    case error(ErrorType)
    
    var errorDescription: String? {
        switch self {
        case .error(let type):
            return type.message
        }
    }
    
    enum ErrorType: Error {
        // HTTP Errors
        case requestFailed(description: String)
        case invalidStatusCode(statuscode: Int)
        case decodingError(error: Error)
        case encodingError(error: Error)
        
        // Authentication Errors
        case invalidCredential
        case missingIDToken
        case credentialRevoked
        case credentialNotFound
        case unknownAuthError(Error)
        
        // General Errors
        case generalError
        case noAuthUserFound
        
        // User Listings Errors
        case deleteSuccess
        
        // Profile Errors
        case inappropriateUsername
        case sensitiveContent
        case sensitiveApiNotEnabled
        case profileUpdateSuccess
        case profileImageUploadFailed
        
        // Listing Form Errors
        case inappropriateField
        case updateSuccess
        case createSuccess
        case notElectric
        case invalidRegistration
        case errorDownloadingImages
        case formInvalid
        
        // JSON Loading Errors
        case fileNotFound(String)
        case dataLoadingError(Error)
        case dataParsingError(Error)
        
        var message: String {
            switch self {
            case .requestFailed(let description):
                return "Request failed: \(description)"
            case .invalidStatusCode(let statuscode):
                return "Invalid status code \(statuscode)"
            case .decodingError(let error):
                return "Decoding error: \(error.localizedDescription)"
            case .encodingError(let error):
                return "Encoding error: \(error.localizedDescription)"
            case .invalidCredential:
                return "The Apple ID credential is invalid. Please try signing in again."
            case .missingIDToken:
                return "The ID token is missing. Please try signing in again."
            case .credentialRevoked:
                return "Your Apple ID credential has been revoked. Please sign in again."
            case .credentialNotFound:
                return "Your Apple ID credential was not found. Please sign in again."
            case .unknownAuthError(let error):
                return "An unknown authentication error occurred: \(error.localizedDescription)"
            case .generalError:
                return "An error occurred. Please try again."
            case .noAuthUserFound:
                return "No authenticated user found."
            case .deleteSuccess:
                return "Listing deleted successfully."
            case .inappropriateUsername:
                return "Please choose a different username."
            case .sensitiveContent:
                return "The selected image contains sensitive content. Please choose a different image."
            case .sensitiveApiNotEnabled:
                return "Please enable Sensitive Content Warning. Go to Settings > Privacy & Security > Sensitive Content Warning."
            case .profileUpdateSuccess:
                return "Profile updated successfully."
            case .inappropriateField:
                return "One of the fields contains prohibited words."
            case .updateSuccess:
                return "Listing updated successfully."
            case .createSuccess:
                return "Listing created successfully."
            case .notElectric:
                return "Your vehicle is not electric."
            case .invalidRegistration:
                return "Invalid registration number."
            case .errorDownloadingImages:
                return "Error retrieving images from server. Please try again."
            case .formInvalid:
                return "Please fill in all required fields and select at least one image."
            case .fileNotFound(let filename):
                return "Couldn't find \(filename) in main bundle."
            case .dataLoadingError(let error):
                return "Couldn't load data from file: \(error.localizedDescription)"
            case .dataParsingError(let error):
                return "Couldn't parse data: \(error.localizedDescription)"
            case .profileImageUploadFailed:
                return "Failed to upload image, please try again."
            }
        }
    }
}
