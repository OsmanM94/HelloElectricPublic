//
//  AuthViewModel.swift
//  Clin
//
//  Created by asia on 22/06/2024.
//

import Foundation
import Supabase
import AuthenticationServices
import CryptoKit
import Factory

@Observable
final class AuthViewModel {
    // MARK: - Enum
    enum AuthenticationState: Equatable {
        case unauthenticated
        case loading
        case authenticated
        case error(String)
    }
    
    // MARK: - Observable properties
    var viewState: AuthenticationState = .unauthenticated
    var displayName: String = ""
    var user: User? = nil
    var showDeleteAlert: Bool = false
    
    init() {
        Task {
            await setupAuthStateListener()
        }
    }
    
    // MARK: - Dependencies
    @ObservationIgnored @Injected(\.supabaseService) private var supabaseService
    
    // MARK: - Main actor functions
    @MainActor
    func signOut() async {
        viewState = .loading
        do {
            try await supabaseService.client.auth.signOut()
            viewState = .unauthenticated
        } catch {
            viewState = .error(AppError.ErrorType.errorSigningOut.message)
        }
    }
    
    // MARK: - Account Deletion
    @MainActor
    func deleteAccount() async  {
        viewState = .loading
        do {
            // Ensure the user is authenticated
            guard let user = try? await supabaseService.client.auth.session.user else { return }
            
            // Delete the user's listing from database
            try await deleteUserListing(userId: user.id)
            
            // Delete the user's profile from database
            try await deleteUserProfile(userId: user.id)
            
            // Sign out the user after successful deletion
             await signOut()
            
            print("DEBUG: User account successfully deleted")
            viewState = .unauthenticated
        } catch {
            print("DEBUG: Error deleting user account: \(error)")
            viewState = .error(AppError.ErrorType.errorDeletingAccount.message)
        }
    }
    
    @MainActor
    func setupAuthStateListener() async {
        await supabaseService.client.auth.onAuthStateChange { event, user in
            Task {
                self.user = user?.user
                self.viewState = user?.user == nil ? .unauthenticated : .authenticated
                self.displayName = user?.user.email ?? UUID().uuidString
            }
        }
    }
    
    @MainActor
    func resetState() {
        viewState = .unauthenticated
    }
   
    // MARK: - Methods
    func handleAppleSignInCompletion(result: Result<ASAuthorization, Error>) {
        viewState = .loading
        Task {
            do {
                guard let credential = try result.get().credential as? ASAuthorizationAppleIDCredential else {
                    viewState = .unauthenticated
                    return
                }
                guard let idToken = credential.identityToken.flatMap({ String(data: $0, encoding: .utf8) }) else {
                    viewState = .unauthenticated
                    return
                }
                
                try await supabaseService.client.auth.signInWithIdToken(
                    credentials: .init(
                        provider: .apple,
                        idToken: idToken
                    )
                )
                print("DEBUG: Successfully signed in with Supabase.")
                viewState = .authenticated
                
                if let userEmail = credential.email {
                    self.displayName = userEmail
                } else {
                    self.displayName = UUID().uuidString
                }
                
            } catch {
                viewState = .unauthenticated
            }
        }
    }
        
    // MARK: - Private methods
    private func deleteUserListing(userId: UUID) async throws {
        do {
            try await supabaseService.client
                .from("car_listing")
                .delete()
                .eq("user_id", value: userId)
                .execute()
        } catch {
            throw error
        }
    }
    
    private func deleteUserProfile(userId: UUID) async throws {
        do {
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
        
        } catch {
            throw error
        }
    }
}
