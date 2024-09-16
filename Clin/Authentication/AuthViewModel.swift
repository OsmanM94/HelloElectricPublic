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
            
            // Delete the user's data from your database (if needed)
            // This step depends on your data structure and requirements
            // For example:
            try await deleteUserData(userId: user.id)
            
            // Delete the user's account from Supabase
            try await supabaseService.client.auth.admin.deleteUser(id: user.id.uuidString)
            
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
    func resetState() {
        viewState = .unauthenticated
    }
    
    // Helper function to delete user data (implement as needed)
    private func deleteUserData(userId: UUID) async throws {
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
    
    // MARK: - Helpers
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
                }
                                
            } catch {
                viewState = .unauthenticated
            }
        }
    }
        
    func setupAuthStateListener() async {
        await supabaseService.client.auth.onAuthStateChange { event, user in
            Task { @MainActor in
                self.user = user?.user
                self.viewState = user?.user == nil ? .unauthenticated : .authenticated
                self.displayName = user?.user.email ?? ""
            }
        }
    }
}
