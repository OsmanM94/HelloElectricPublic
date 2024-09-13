//
//  MockProfileService.swift
//  Clin
//
//  Created by asia on 12/09/2024.
//

import Foundation

class MockProfileService: ProfileServiceProtocol {
    var mockProfile: Profile?
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "MockProfileService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
    var updatedProfile: Profile?
    var mockUserID = UUID()

    func loadProfile(for userID: UUID) async throws -> Profile {
        if shouldThrowError {
            throw errorToThrow
        }
        guard let profile = mockProfile else {
            throw NSError(domain: "MockProfileService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No mock profile set"])
        }
        return profile
    }
    
    func updateProfile(_ profile: Profile) async throws {
        if shouldThrowError {
            throw errorToThrow
        }
        updatedProfile = profile
    }
    
    func getCurrentUserID() async throws -> UUID {
        if shouldThrowError {
            throw errorToThrow
        }
        return mockUserID
    }

    // Helper methods for testing
    func setMockProfile(_ profile: Profile) {
        mockProfile = profile
    }

    func setMockUserID(_ userID: UUID) {
        mockUserID = userID
    }

    func reset() {
        mockProfile = nil
        shouldThrowError = false
        errorToThrow = NSError(domain: "MockProfileService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        updatedProfile = nil
        mockUserID = UUID()
    }
}
