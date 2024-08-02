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
             await verifySignInWithAppleAuthenticationState()
         }
    }
    
    func handleAppleSignInCompletion(result: Result<ASAuthorization, Error>) {
        print("Starting Apple sign-in completion handling.")
        authenticationState = .authenticating
        Task {
            do {
                guard let credential = try result.get().credential as? ASAuthorizationAppleIDCredential else {
                    print("Failed to cast credential as ASAuthorizationAppleIDCredential.")
                    authenticationState = .unauthenticated
                    return
                }
                print("Successfully retrieved AppleID credential.")
                guard let idToken = credential.identityToken.flatMap({ String(data: $0, encoding: .utf8) }) else {
                    print("Failed to retrieve ID token from credential.")
                    authenticationState = .unauthenticated
                    return
                }
                
                try await Supabase.shared.client.auth.signInWithIdToken(
                    credentials: .init(
                        provider: .apple,
                        idToken: idToken
                    )
                )
                print("Successfully signed in with Supabase.")
                authenticationState = .authenticated
                
                if let userEmail = credential.email {
                    self.displayName = userEmail
                }
                                
            } catch let error as AuthenticationErrors {
                print("AppleAuthError encountered: \(error.localizedDescription)")
                authenticationState = .unauthenticated
                self.errorMessage = error.localizedDescription
                dump(error)
            } catch {
                print("Unexpected error encountered: \(error.localizedDescription)")
                authenticationState = .unauthenticated
                self.errorMessage = error.localizedDescription
                dump(error)
            }
        }
    }
    
    func verifySignInWithAppleAuthenticationState(userID: String? = nil) async {
           let appleIDProvider = ASAuthorizationAppleIDProvider()
           let userID = userID ?? self.user?.id.uuidString

           guard let userID = userID else {
               authenticationState = .unauthenticated
               return
           }
           
           do {
               let credentialState = try await appleIDProvider.credentialState(forUserID: userID)
               switch credentialState {
               case .authorized:
                   break // The Apple ID credential is valid.
               case .revoked:
                   self.errorMessage = AuthenticationErrors.credentialRevoked.localizedDescription
                   await signOut()
               case .notFound:
                   self.errorMessage = AuthenticationErrors.credentialNotFound.localizedDescription
                   await signOut()
               default:
                   break
               }
           } catch {
               self.errorMessage = AuthenticationErrors.unknownError(error).localizedDescription
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
    
    private func setupAuthStateListener() async {
        await Supabase.shared.client.auth.onAuthStateChange { event, user in
            Task { @MainActor in
                self.user = user?.user
                self.authenticationState = user?.user == nil ? .unauthenticated : .authenticated
                self.displayName = user?.user.email ?? ""
            }
        }
    }
    
}
