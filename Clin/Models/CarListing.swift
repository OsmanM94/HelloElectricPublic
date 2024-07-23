//
//  Listing.swift
//  Clin
//
//  Created by asia on 23/06/2024.
//

import Foundation

struct CarListing: Identifiable, Codable, Hashable {
    var id: Int?
    var createdAt: Date
    var imagesURL: [URL]
    var make: String
    var model: String
    var condition: String
    var mileage: Double
    var yearOfManufacture: String
    var price: Double
    var description: String
    var range: String
    var colour: String
    var publicChargingTime: String?
    var homeChargingTime: String?
    var batteryCapacity: String?
    var powerBhp: String?
    var regenBraking: String?
    var warranty: String?
    var serviceHistory: String?
    var numberOfOwners: String?
    var userID: UUID
    
    enum CodingKeys: String, CodingKey {
        case id
        case imagesURL
        case make
        case model
        case condition
        case mileage
        case yearOfManufacture
        case price
        case description
        case range
        case colour
        case publicChargingTime
        case homeChargingTime
        case batteryCapacity
        case powerBhp
        case regenBraking
        case warranty
        case serviceHistory
        case numberOfOwners
        case createdAt = "created_at"
        case userID = "user_id"
    }
}

