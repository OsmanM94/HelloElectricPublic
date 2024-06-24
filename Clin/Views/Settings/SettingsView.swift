//
//  SettingsView.swift
//  Clin
//
//  Created by asia on 22/06/2024.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(AuthViewModel.self) private var viewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section("In app name") {
                    Text("Guest")
                }

                Section("Manage") {
                    NavigationLink("My listings", destination: {})
                    NavigationLink("Saved", destination: {})
                }

                Section("Notifications") {
                    Text("Notify me")
                }

                Section("Logged in as \(viewModel.displayName) ") {
                    SignOutButton(action: { Task { await viewModel.signOut() } }, description: "Sign out")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
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
