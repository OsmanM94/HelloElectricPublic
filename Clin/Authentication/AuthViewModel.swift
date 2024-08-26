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
    // MARK: - Enums
    enum AuthenticationState {
        case unauthenticated
        case authenticating
        case authenticated
    }
    
    // MARK: - Observable properties
    var authenticationState: AuthenticationState = .unauthenticated
    var displayName: String = ""
    var user: User? = nil
    
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
        do {
            try await supabaseService.client.auth.signOut()
            authenticationState = .unauthenticated
        } catch {
            print("DEBUG: Error signing out")
        }
    }
    
    // MARK: - Helpers
    func handleAppleSignInCompletion(result: Result<ASAuthorization, Error>) {
        print("DEBUG: Starting Apple sign-in completion handling.")
        authenticationState = .authenticating
        Task {
            do {
                guard let credential = try result.get().credential as? ASAuthorizationAppleIDCredential else {
                    print("DEBUG: Failed to cast credential as ASAuthorizationAppleIDCredential.")
                    authenticationState = .unauthenticated
                    return
                }
                print("DEBUG: Successfully retrieved AppleID credential.")
                guard let idToken = credential.identityToken.flatMap({ String(data: $0, encoding: .utf8) }) else {
                    print("DEBUG: Failed to retrieve ID token from credential.")
                    authenticationState = .unauthenticated
                    return
                }
                
                try await supabaseService.client.auth.signInWithIdToken(
                    credentials: .init(
                        provider: .apple,
                        idToken: idToken
                    )
                )
                print("DEBUG: Successfully signed in with Supabase.")
                authenticationState = .authenticated
                
                if let userEmail = credential.email {
                    self.displayName = userEmail
                }
                                
            } catch let error as AuthenticationErrors {
                print("DEBUG: AppleAuthError encountered: \(error.localizedDescription)")
                authenticationState = .unauthenticated
                dump(error)
            } catch {
                print("DEBUG: Unexpected error encountered: \(error.localizedDescription)")
                authenticationState = .unauthenticated
                dump(error)
            }
        }
    }
        
    func setupAuthStateListener() async {
        await supabaseService.client.auth.onAuthStateChange { event, user in
            Task { @MainActor in
                self.user = user?.user
                self.authenticationState = user?.user == nil ? .unauthenticated : .authenticated
                self.displayName = user?.user.email ?? ""
            }
        }
    }
}
