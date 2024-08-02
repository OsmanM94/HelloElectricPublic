//
//  AuthenticationView.swift
//  Clin
//
//  Created by asia on 22/06/2024.
//

import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    
    @Environment(AuthViewModel.self) private var viewModel
   
    var body: some View {
        NavigationStack {
            Group {
                ScrollView(.vertical) {
                    VStack(spacing: 15) {
                        Image(decorative: "ev")
                            .resizable()
                            .scaledToFit()
                        WelcomeText()
                            .padding(.bottom)
                        
                        SignInWithAppleButton(.continue) { request in
                            request.requestedScopes = [.email]
                        } onCompletion: { result in
                            viewModel.handleAppleSignInCompletion(result: result)
                        }
                        .frame(maxWidth: .infinity, minHeight: 55)
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Sign in")
        }
    }
}

#Preview {
    AuthenticationView()
        .environment(AuthViewModel())
}

fileprivate struct WelcomeText: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Why Sign in with Apple?")
                .font(.title3)
                .fontWeight(.bold)
                
            Text("Fast and Secure:")
                .font(.headline)
                .fontWeight(.semibold)
            Text("Use your Apple ID for a quick and secure sign-in process.")
                .font(.subheadline)
            
            Text("Privacy First:")
                .font(.headline)
                .fontWeight(.semibold)
            Text("Apple ensures that your personal information stays private and secure.")
                .font(.subheadline)
            
        }
        .padding(.horizontal, 30)
    }
}
