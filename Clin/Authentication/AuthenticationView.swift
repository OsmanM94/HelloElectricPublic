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
                VStack(spacing: 30) {
                    if let uiImage = UIImage(named: "ev")?.resize(300, 300) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .frame(width: 300, height: 300)
                           
                    } else {
                        Image(decorative: "ev")
                            .frame(width: 300, height: 300)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    WelcomeText()
                    
                    SignInWithAppleButton(.continue) { request in
                        request.requestedScopes = [.email]
                    } onCompletion: { result in
                        viewModel.handleAppleSignInCompletion(result: result)
                    }
                    .id(signInAppleButtonId)
                    .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
                    .onChange(of: colorScheme, { oldValue, newValue in
                        signInAppleButtonId = UUID().uuidString
                    })
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Welcome")
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.green.opacity(0.2)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
            )
        }
    }
}

#Preview {
    AuthenticationView()
        .environment(AuthViewModel())
}

fileprivate struct WelcomeText: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Why Sign in with Apple?")
                .font(.title2.bold())
                .foregroundStyle(.primary)
            
            FeatureRow(title: "Fast and Secure", description: "Use your Apple ID for a quick and secure sign-in process.")
            
            FeatureRow(title: "Privacy First", description: "Apple ensures that your personal information stays private and secure.")
        }
        .padding(.horizontal, 30)
    }
}

fileprivate struct FeatureRow: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
