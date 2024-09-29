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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 40) {
                    imageHeader
                    welcomeText
                    signInAppleButton
                }
                .padding(.top, 50)
                
                termsAndConditionsLink
                
            }
            .navigationTitle("Welcome")
        }
    }
    
    private var imageHeader: some View {
        Image(decorative: "electric-car")
            .resizable()
            .scaledToFill()
            .frame(width: 100, height: 100)
    }
    
    private var signInAppleButton: some View {
        SignInWithAppleButton(.continue) { request in
            request.requestedScopes = [.email]
        } onCompletion: { result in
            viewModel.handleAppleSignInCompletion(result: result)
        }
        .id(viewModel.signInAppleButtonId)
        .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
        .onChange(of: colorScheme) { _, _ in
            viewModel.signInAppleButtonId = UUID().uuidString
        }
        .frame(maxWidth: .infinity)
        .frame(height: 55)
        .padding(.horizontal)
    }
    
    private var termsAndConditionsLink: some View {
        NavigationLink {
            TermsAndConditionsView()
        } label: {
            Text("Terms and Conditions")
                .font(.subheadline)
        }
        .tint(.primary)
        .padding(.top)
    }
    
    private var welcomeText: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Why continue with Apple?")
                .font(.title2.bold())
            
            FeatureCell(title: "Fast and Secure", description: "Use your Apple ID for a quick and secure sign-in process.")
            
            FeatureCell(title: "Privacy First", description: "Apple ensures that your personal information stays private and secure.")
        }
        .padding(.horizontal, 30)
        .fontDesign(.rounded)
    }
}

fileprivate struct FeatureCell: View {
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
