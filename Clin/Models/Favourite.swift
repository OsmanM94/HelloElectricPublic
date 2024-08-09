//
//  FavouriteListing.swift
//  Clin
//
//  Created by asia on 25/07/2024.
//

import Foundation

struct Favourite: Codable, Identifiable, Hashable {
    var id: Int?
    let userID: UUID
    let listingID: Int
    var imagesURL: [URL]
    var thumbnailsURL: [URL]
    var make: String
    var model: String
    var condition: String
    var mileage: Double
    var price: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case listingID = "listing_id"
        case imagesURL = "images"
        case thumbnailsURL = "thumbnails"
        case make
        case model
        case condition
        case mileage
        case price
    }
}


