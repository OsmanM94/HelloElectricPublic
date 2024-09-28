//
//  ProfileService.swift
//  Clin
//
//  Created by asia on 19/08/2024.
//

import Foundation
import Factory

final class ProfileService: ProfileServiceProtocol {
    @Injected(\.databaseService) private var databaseService
    @Injected(\.supabaseService) private var supabaseService
    
    func loadProfile(for userID: UUID) async throws -> Profile {
        let profile: Profile = try await databaseService.loadSingleItemByField(
            from: "profiles",
            field: "user_id",
            uuid: userID
        )
        return profile
    }
    
    func updateProfile(_ profile: Profile) async throws {
        try await databaseService
            .updateItemByUserID(
                profile,
                in: "profiles",
                userID: profile.userID
            )
    }
    
    func getCurrentUserID() async throws -> UUID {
        let currentUser = try await supabaseService.client.auth.session.user
        return currentUser.id
    }
}
