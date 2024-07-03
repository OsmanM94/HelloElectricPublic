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
  
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case userID = "user_id"
        case avatarURL = "avatar_url"
        case updatedAt = "updated_at"
    }
}
