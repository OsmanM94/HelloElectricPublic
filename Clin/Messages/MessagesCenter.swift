//
//  Errors.swift
//  Clin
//
//  Created by asia on 10/09/2024.
//

import Foundation


enum MessageCenter: Error, LocalizedError {
    case error(MessageType)
    
    var errorDescription: String? {
        switch self {
        case .error(let type):
            return type.message
        }
    }
    
    enum MessageType: Error {
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
        
        // User Listings
        case deleteSuccess
        case refreshSuccess
        
        // Profile
        case inappropriateTextfieldInput
        case sensitiveContent
        case sensitiveApiNotEnabled
        case profileUpdateSuccess
        case profileImageUploadFailed
        
        // Listing Form
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
        
        // Companies House
        case companyDissolved
        case companyLoadingFailure
        
        // Authentication
        case errorSigningOut
        case errorDeletingAccount
        
        // News
        case failedToLoadNews
        
        // FaceID
        case biometricsNotAvailable
        case authenticationFailed
        
        // Chart
        case noAvailableData
        
        var message: String {
            switch self {
            case .requestFailed(let description):
                return "Network request failed: \(description). Please check your internet connection and try again."
            case .invalidStatusCode(let statusCode):
                return "Server returned an unexpected status code (\(statusCode)). Please try again later."
            case .decodingError(let error):
                return "There was an issue processing the data from the server. Error: \(error). Please contact support if this persists."
            case .encodingError(let error):
                return "There was an issue preparing the data to send. Error: \(error). Please try again or contact support."
            case .invalidCredential, .missingIDToken, .credentialRevoked, .credentialNotFound:
                return "There was an issue with your account authentication. Please sign out and sign in again."
            case .unknownAuthError(let error):
                return "An unexpected authentication error occurred: \(error). Please try again or contact support."
            case .generalError:
                return "An unexpected error occurred. Please try again or contact support if the issue persists."
            case .noAuthUserFound:
                return "You need to be signed in to perform this action. Please sign in and try again."
            case .deleteSuccess:
                return "The listing was successfully deleted."
            case .refreshSuccess:
                return "The data was successfully refreshed."
            case .inappropriateTextfieldInput, .inappropriateField:
                return "Please review your input. Some fields contain inappropriate content."
            case .sensitiveContent:
                return "The selected image contains sensitive content. Please choose a different image or contact support for assistance."
            case .sensitiveApiNotEnabled:
                return "Sensitive content checking is not enabled. Please enable it in Settings > Privacy & Security > Sensitive Content Warning."
            case .profileUpdateSuccess:
                return "Your profile has been successfully updated."
            case .updateSuccess:
                return "The listing has been successfully updated."
            case .createSuccess:
                return "The listing has been successfully created."
            case .notElectric:
                return "This feature is only available for electric vehicles."
            case .invalidRegistration:
                return "Registration number is not valid."
            case .errorDownloadingImages:
                return "There was an issue downloading images. Please check your internet connection and try again."
            case .formInvalid:
                return "Please ensure all required fields are filled and at least one image is selected before submitting."
            case .fileNotFound(let filename):
                return "A required file (\(filename)) is missing. Please reinstall the app or contact support."
            case .dataLoadingError(let error), .dataParsingError(let error):
                return "There was an issue loading the necessary data. Error: \(error). Please try again or contact support."
            case .profileImageUploadFailed:
                return "We couldn't upload your profile image. Please try again or choose a different image."
            case .companyDissolved:
                return "The requested company is no longer active."
            case .companyLoadingFailure:
                return "We couldn't find information for the requested company."
            case .errorSigningOut:
                return "There was an issue signing you out. Please close the app, reopen it, and try again."
            case .errorDeletingAccount:
                return "We encountered an issue while trying to delete your account. Please try again or contact support for assistance."
            case .failedToLoadNews:
                return "We couldn't load the latest news."
            case .biometricsNotAvailable:
                return "Biometric authentication is not available on this device. Please use an alternative authentication method."
            case .authenticationFailed:
                return "Authentication failed. Please ensure your biometric sensor is clean and try again, or use an alternative authentication method."
            case .noAvailableData:
                return "There's no data available for your request. Please try again later or modify your search criteria."
            }
        }
    }
}
