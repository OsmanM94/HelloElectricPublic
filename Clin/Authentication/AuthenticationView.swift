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
    @Environment(\.colorScheme) private var colorScheme
    @State private var signInAppleButtonId = UUID().uuidString
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 40) {
                    Image(decorative: "electric-car")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                    
                    WelcomeText()
                    
                    SignInWithAppleButton(.continue) { request in
                        request.requestedScopes = [.email]
                    } onCompletion: { result in
                        viewModel.handleAppleSignInCompletion(result: result)
                    }
                    .id(signInAppleButtonId)
                    .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
                    .onChange(of: colorScheme) { _, _ in
                        signInAppleButtonId = UUID().uuidString
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .padding(.horizontal)
                }
                .padding(.top, 50)
                
            }
            .navigationTitle("Welcome")
        }
    }
}

fileprivate struct WelcomeText: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Why Sign in with Apple?")
                .font(.title2.bold())
            
            FeatureRow(title: "Fast and Secure", description: "Use your Apple ID for a quick and secure sign-in process.")
            
            FeatureRow(title: "Privacy First", description: "Apple ensures that your personal information stays private and secure.")
        }
        .padding(.horizontal, 30)
        .fontDesign(.rounded)
    }
}

fileprivate struct FeatureRow: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    AuthenticationView()
        .environment(AuthViewModel())
}
