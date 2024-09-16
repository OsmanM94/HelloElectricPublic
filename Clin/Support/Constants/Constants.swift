//
//  Constants.swift
//  Clin
//
//  Created by asia on 16/09/2024.
//

import Foundation

struct AppConstants {
    struct Contact {
        static let supportEmail = "support@yahoo.com"
        static let phoneNumber = "07466861603"
    }
    
    struct URL {
        static let website = "https://www.example.com"
        static let privacyPolicy = "https://www.example.com/privacy"
    }
    
    struct App {
        static let name = "MyAwesomeApp"
        static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
}
