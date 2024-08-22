//
//  EVSpecific.swift
//  Clin
//
//  Created by asia on 21/08/2024.
//

import Foundation

struct EVFeatures: Identifiable, Codable {
    var id: Int?
    let bodyType: [String]
    let yearOfManufacture: [String]
    let range: [String]
    let homeChargingTime: [String]
    let publicChargingTime: [String]
    let batteryCapacity: [String]
    let condition: [String]
    let regenBraking: [String]
    let warranty: [String]
    let serviceHistory: [String]
    let owners: [String]
    let powerBhp: [String]
    let colours: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case bodyType = "body_type"
        case yearOfManufacture = "year"
        case range
        case homeChargingTime = "home_charge"
        case publicChargingTime = "public_charge"
        case batteryCapacity = "battery_capacity"
        case condition
        case regenBraking = "regen_braking"
        case warranty
        case serviceHistory = "service_history"
        case owners
        case powerBhp = "power_bhp"
        case colours
    }
}



