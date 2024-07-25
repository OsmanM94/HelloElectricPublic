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
        case imagesURL = "images"
        case make
        case model
        case condition
        case mileage
        case yearOfManufacture = "year"
        case price
        case description
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
    }
}

extension Listing {
    static var sampleData: [Listing] = [Listing(
        id: 1,
        createdAt: Date(),
        imagesURL: [URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/avatars/15ECE008-ABF5-43CF-8DAF-1A26A342FFAF.jpeg?download=")!],
        make: "Tesla",
        model: "Model S supercharger 2024",
        condition: "Used",
        mileage: 100000,
        yearOfManufacture: "2023",
        price: 8900,
        description: "A great electric vehicle with long range.",
        range: "396 miles",
        colour: "Red",
        publicChargingTime: "1 hour",
        homeChargingTime: "10 hours",
        batteryCapacity: "100 kWh",
        powerBhp: "1020",
        regenBraking: "Yes",
        warranty: "4 years",
        serviceHistory: "Full",
        numberOfOwners: "1",
        userID: UUID()
    ),
    
    Listing(
        id: 2,
        createdAt: Date(),
        imagesURL: [URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/avatars/15ECE008-ABF5-43CF-8DAF-1A26A342FFAF.jpeg?download=")!],
        make: "Mercedes",
        model: "Mercedes-Benz EQA Class",
        condition: "Used",
        mileage: 120000,
        yearOfManufacture: "2024",
        price: 9900,
        description: "A great electric vehicle with long range.",
        range: "396 miles",
        colour: "Red",
        publicChargingTime: "1 hour",
        homeChargingTime: "10 hours",
        batteryCapacity: "100 kWh",
        powerBhp: "1020",
        regenBraking: "Yes",
        warranty: "4 years",
        serviceHistory: "Full",
        numberOfOwners: "1",
        userID: UUID()
    )]
}

