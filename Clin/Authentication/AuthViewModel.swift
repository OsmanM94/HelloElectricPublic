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
    var signInAppleButtonId = UUID().uuidString
    
    init() {
        Task {
            await setupAuthStateListener()
        }
    }
    
    // MARK: - Dependencies
    @ObservationIgnored @Injected(\.authService) private var authService
    
    // MARK: - Main actor functions
    @MainActor
    func signOut() async {
        viewState = .loading
        do {
            try await authService.signOut()
            viewState = .unauthenticated
        } catch {
            viewState = .error(MessageCenter.MessageType.errorSigningOut.message)
        }
    }
    
    // MARK: - Account Deletion
    @MainActor
    func deleteAccount() async  {
        viewState = .loading
        do {
            // Ensure the user is authenticated
            guard let user = try await authService.getCurrentUser() else { return }
            
            // Delete the user's listing from database
            try await authService.deleteUserTable(from: "car_listing", userId: user.id)
            
            // Delete the user's favourites
            try await authService.deleteUserTable(from: "favourite_listing", userId: user.id)
            
            // Delete user images from storage
            try await authService.deleteUserImages(userId: user.id)
            
            // Delete the user's profile from storage
            try await authService.deleteUserProfile(userId: user.id)
            
            // Sign out the user after successful deletion
            await signOut()
            
            viewState = .unauthenticated
        } catch {
            viewState = .error(MessageCenter.MessageType.errorDeletingAccount.message)
        }
    }
    
    @MainActor
    func setupAuthStateListener() async {
        do {
            try await authService.setupAuthStateListener { [weak self] event, session in
                Task { [weak self] in
                    guard let self = self else { return }
                    self.user = session?.user
                    self.viewState = session?.user == nil ? .unauthenticated : .authenticated
                    self.displayName = session?.user.email ?? UUID().uuidString
                }
            }
        } catch {
            self.viewState = .unauthenticated
        }
    }
    
    @MainActor
    func resetState() {
        viewState = .unauthenticated
    }
    
    // MARK: - Functions
    @MainActor
    func handleAppleSignInCompletion(result: Result<ASAuthorization, Error>) {
        self.viewState = .loading
        
        Task { [weak self] in
            guard let self = self else { return }
            do {
                guard let credential = try result.get().credential as? ASAuthorizationAppleIDCredential else {
                    self.viewState = .unauthenticated
                    return
                }
                guard let idToken = credential.identityToken.flatMap({ String(data: $0, encoding: .utf8) }) else {
                    self.viewState = .unauthenticated
                    return
                }
                
                try await self.authService.signInWithApple(idToken: idToken)
                self.viewState = .authenticated
                
                if let userEmail = credential.email {
                    self.displayName = userEmail
                } else {
                    self.displayName = UUID().uuidString
                }
                
            } catch {
                self.viewState = .unauthenticated
            }
        }
    }
}
