//
//  Notification.swift
//  Clin
//
//  Created by asia on 08/09/2024.
//

import Foundation

struct Notification: Identifiable, Codable {
    let id: Int
    let make: String
    let model: String
    let location: String
    let price: Double
    let year: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case make
        case model
        case location
        case price
        case year
    }
}
