//
//  AuthenticationServices.swift
//  Clin
//
//  Created by asia on 29/09/2024.
//

import Foundation
import Supabase
import Factory

class SupabaseAuthService: AuthServiceProtocol {
    @Injected(\.supabaseService) private var supabaseService
    
    func signOut() async throws {
        try await supabaseService.client.auth.signOut()
    }
    
    func signInWithApple(idToken: String) async throws {
        try await supabaseService.client.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: idToken
            )
        )
    }
    
    func deleteUserListing(userId: UUID) async throws {
        try await supabaseService.client
            .from("car_listing")
            .delete()
            .eq("user_id", value: userId)
            .execute()
    }
    
    func deleteUserProfile(userId: UUID) async throws {
        let profile = Profile(
            username: "Private Seller",
            avatarURL: URL(
                string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/electric-car.png"
            ),
            updatedAt: nil,
            userID: userId,
            isDealer: false,
            address: nil,
            postcode: nil,
            location: nil,
            website: nil,
            companyNumber: nil
        )
        
        try await supabaseService.client
            .from("profiles")
            .update(profile)
            .eq("user_id", value: userId)
            .execute()
    }
    
    func deleteUserImages(userId: UUID) async throws {
        let bucket = "car_images"
        let folderPath = "\(userId)"
        
        let files = try await supabaseService.client.storage
            .from(bucket)
            .list(path: folderPath)
        
        if !files.isEmpty {
            let filePaths = files.map { "\(folderPath)/\(($0.name).removingPercentEncoding ?? $0.name)" }
            
            _ = try await supabaseService.client.storage
                .from(bucket)
                .remove(paths: filePaths)
        }
    }
    
    func setupAuthStateListener(completion: @Sendable @escaping (AuthChangeEvent, Session?) -> Void) async {
        await supabaseService.client.auth.onAuthStateChange(completion)
    }
    
    func getCurrentUser() async throws -> User? {
        try await supabaseService.client.auth.session.user
    }
}
