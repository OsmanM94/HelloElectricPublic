//
//  ProfileError.swift
//  Clin
//
//  Created by asia on 04/07/2024.
//

import Foundation

enum ProfileError: String, Error {
    case cooldownActive = "Please wait for the cooldown period to end before updating again."
    case inappropriateUsername = "Please choose a different username."
    case noAvatarImage = "No avatar image selected"
    case sensitiveContent = "The selected image contains sensitive content. Please choose a different image."
    case generalError = "An error occurred. Please try again."

    var message: String {
        return self.rawValue
    }
}
