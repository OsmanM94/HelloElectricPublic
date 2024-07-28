//
//  AppleAuthError.swift
//  Clin
//
//  Created by asia on 22/06/2024.
//

import Foundation


enum AuthenticationErrors: Error, LocalizedError {
    case invalidCredential
    case missingIDToken
    case credentialRevoked
    case credentialNotFound
    case unknownError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "The Apple ID credential is invalid. Please try signing in again."
        case .missingIDToken:
            return "The ID token is missing. Please try signing in again."
        case .credentialRevoked:
            return "Your Apple ID credential has been revoked. Please sign in again."
        case .credentialNotFound:
            return "Your Apple ID credential was not found. Please sign in again."
        case .unknownError(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}
