//
//  Listing.swift
//  Clin
//
//  Created by asia on 23/06/2024.
//

import Foundation

struct Listing: Identifiable, Codable, Hashable {
    var id: Int?
    var createdAt: Date
    var imagesURL: [URL]
    var thumbnailsURL: [URL]
    var make: String
    var model: String
    var bodyType: String
    var condition: String
    var mileage: Double
    var location: String
    var yearOfManufacture: String
    var price: Double
    var phoneNumber: String
    var textDescription: String
    var range: String
    var colour: String
    var publicChargingTime: String
    var homeChargingTime: String
    var batteryCapacity: String
    var powerBhp: String
    var regenBraking: String
    var warranty: String
    var serviceHistory: String
    var numberOfOwners: String
    var userID: UUID
    var isPromoted: Bool
    var promotionActivated: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case imagesURL = "images"
        case thumbnailsURL = "thumbnails"
        case make
        case model
        case bodyType = "body_type"
        case condition
        case mileage
        case location
        case yearOfManufacture = "year"
        case price
        case phoneNumber = "phone_number"
        case textDescription = "text_description"
        case range
        case colour
        case publicChargingTime = "public_charging"
        case homeChargingTime = "home_charging"
        case batteryCapacity = "battery_capacity"
        case powerBhp = "power_bhp"
        case regenBraking = "regen_braking"
        case warranty
        case serviceHistory = "service_history"
        case numberOfOwners = "owners"
        case createdAt = "created_at"
        case userID = "user_id"
        case isPromoted = "is_promoted"
        case promotionActivated = "promotion_activated_at"
    }
}


