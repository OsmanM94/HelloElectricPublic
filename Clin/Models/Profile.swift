//
//  UserProfile.swift
//  Clin
//
//  Created by Osman M. on 26/06/2024.
//
import Foundation

struct Profile: Codable {
    var id: Int?
    var username: String?
    var avatarURL: URL?
    var updatedAt: Date?
    var userID: UUID
//    var isDealer: Bool?
//    var address: String?
//    var postCode: String?
//    var location: String?
  
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case avatarURL = "avatar_url"
        case updatedAt = "updated_at"
        case userID = "user_id"
//        case isDealer = "is_dealer"
//        case address = "address"
//        case postCode = "post_code"
//        case location = "location"
    }
}
