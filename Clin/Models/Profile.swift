//
//  UserProfile.swift
//  Clin
//
//  Created by Osman M. on 26/06/2024.
//
import Foundation

struct Profile: Codable, Equatable {
    var id: Int?
    var username: String?
    var avatarURL: URL?
    var createdAt: Date?
    var updatedAt: Date?
    var userID: UUID
    var isDealer: Bool?
    var address: String?
    var postcode: String?
    var location: String?
    var website: String?
    var companyNumber: String?
  
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case avatarURL = "avatar_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userID = "user_id"
        case isDealer = "is_dealer"
        case address = "address"
        case postcode = "postcode"
        case location = "location"
        case website = "website"
        case companyNumber = "company_number"
    }
}
