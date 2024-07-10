//
//  SettingsView.swift
//  Clin
//
//  Created by asia on 22/06/2024.
//

import SwiftUI

struct AccountView: View {
    
    @Environment(AuthViewModel.self) private var viewModel
 
    var body: some View {
        NavigationStack {
            Form {
                Section("Manage") {
                    NavigationLink("Profile", destination: { ProfileView() })
                    NavigationLink("My listings", destination: {
                        UserListingView()
                    })
                    NavigationLink("Saved", destination: {})
                }
                
                Section("Safety") {
                    NavigationLink("How to buy and sell", destination: {
                        SafetyView()
                    })
                }
                
                DisclosureGroup("Legal") {
                    NavigationLink("Terms and Conditions", destination: TermsAndConditionsView())
                    NavigationLink("Privacy Policy", destination: PrivacyPolicyView())
                }
                
                Section("Notifications") {
                    Text("Notify me")
                }
                
                Section("Haptic feedback") {
                    Text("Turn on")
                }
                
                Section("Signed in as \(viewModel.displayName) ") {
                    SignOutButton(action: { Task { await viewModel.signOut() } }, description: "Sign out")
                }
                
                HStack {
                    Text("Made in")
                        .italic()
                    Image("uk")
                        .resizable()
                        .scaledToFit()
                }
                .frame(maxWidth: .infinity, maxHeight: 30)
                .listRowBackground(Color(.systemGray6))
                
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AccountView()
        .environment(AuthViewModel())
}

struct SignOutButton: View {
    
    let action: () -> Void
    let description: String
    @State private var isSigningOut: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button(role: .destructive, action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isSigningOut = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    action()
                    isSigningOut = false
                }
            }, label: {
                if isSigningOut {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Sign Out")
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                }
            })
        }
        .buttonStyle(.plain)
    }
}
