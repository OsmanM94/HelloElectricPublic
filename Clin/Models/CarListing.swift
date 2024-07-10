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
    var make: String
    var userID: UUID
    
    enum CodingKeys: String, CodingKey {
       case id, make
       case createdAt = "created_at"
       case userID = "user_id"
    }
}

