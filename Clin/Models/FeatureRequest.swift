//
//  FeatureRequest.swift
//  Clin
//
//  Created by asia on 27/09/2024.
//

import Foundation

struct FeatureRequest: Identifiable, Codable {
    let id: Int?
    let name: String?
    let title: String
    let description: String
    let pending: Bool
    let approved: Bool
    let rejected: Bool
    let createdAt: Date
    let comments: String?
    let userId: UUID
    var voteCount: Int
    var votedUserIds: [UUID]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "name"
        case createdAt = "created_at"
        case title
        case description
        case pending
        case approved
        case rejected
        case comments = "admin_comments"
        case userId = "user_id"
        case voteCount = "vote_count"
        case votedUserIds = "voted_user_ids"
    }
    
    var status: FeatureRequestStatus {
        if approved {
            return .approved
        } else if rejected {
            return .rejected
        } else { return .pending }
    }
    
    mutating func vote(userId: UUID) {
           if !votedUserIds.contains(userId) {
               voteCount += 1
               votedUserIds.append(userId)
           }
       }
       
       mutating func unvote(userId: UUID) {
           if votedUserIds.contains(userId) {
               voteCount -= 1
               votedUserIds.removeAll { $0 == userId }
           }
       }
       
       func hasVoted(userId: UUID) -> Bool {
           votedUserIds.contains(userId)
       }
}

enum FeatureRequestStatus: String, CaseIterable {
    case pending = "Pending"
    case approved = "Approved"
    case rejected = "Rejected"
}

extension FeatureRequest {
    init(id: Int, name: String, title: String, description: String, status: FeatureRequestStatus, createdAt: Date, comments: String, userId: UUID, voteCount: Int, votedUserIds: [UUID]) {
        self.id = id
        self.name = name
        self.title = title
        self.description = description
        self.createdAt = createdAt
        self.comments = comments
        self.userId = userId
        self.voteCount = voteCount
        self.votedUserIds = votedUserIds
        
        switch status {
        case .pending:
            self.pending = true
            self.approved = false
            self.rejected = false
        case .approved:
            self.pending = false
            self.approved = true
            self.rejected = false
        case .rejected:
            self.pending = false
            self.approved = false
            self.rejected = true
        }
    }
}
