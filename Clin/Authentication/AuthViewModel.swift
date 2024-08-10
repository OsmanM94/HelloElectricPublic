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


@Observable
final class AuthViewModel {
    var flow: AuthenticationFlow = .login
    var authenticationState: AuthenticationState = .unauthenticated
    var errorMessage: String = ""
    var displayName: String = ""
    var user: User? = nil
   
     init()  {
         Task {
             await setupAuthStateListener()
         }
    }
    
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
                
                try await Supabase.shared.client.auth.signInWithIdToken(
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
                self.errorMessage = error.localizedDescription
                dump(error)
            } catch {
                print("DEBUG: Unexpected error encountered: \(error.localizedDescription)")
                authenticationState = .unauthenticated
                self.errorMessage = error.localizedDescription
                dump(error)
            }
        }
    }
        
    @MainActor
    func signOut() async {
        do {
            try await Supabase.shared.client.auth.signOut()
            authenticationState = .unauthenticated
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func setupAuthStateListener() async {
        await Supabase.shared.client.auth.onAuthStateChange { event, user in
            Task { @MainActor in
                self.user = user?.user
                self.authenticationState = user?.user == nil ? .unauthenticated : .authenticated
                self.displayName = user?.user.email ?? ""
            }
        }
    }
    
}
