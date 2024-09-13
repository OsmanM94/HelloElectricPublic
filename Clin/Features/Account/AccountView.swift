//
//  SettingsView.swift
//  Clin
//
//  Created by asia on 22/06/2024.
//

import SwiftUI

struct AccountView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Manage") {
                    NavigationLink {
                       LazyView(PrivateProfileViewContainer())
                    } label: {
                        Label("Profile", systemImage: "person.circle")
                    }
                    
                    NavigationLink {
                        LazyView(UserListingsContainer())
                    } label: {
                        Label("My listings", systemImage: "list.bullet")
                    }
                    
                    NavigationLink {
                        LazyView(FavouriteListingContainer())
                    } label: {
                        Label("Saved", systemImage: "heart")
                    }
                }
                
                Section("Legal") {
                    NavigationLink {
                        LazyView(LegalView())
                    } label: {
                        Label("Documents", systemImage: "doc.text")
                    }
                }
                
                Section("Support") {
                    NavigationLink {
                        LazyView(SupportCenterView())
                    } label: {
                        Label("Support", systemImage: "lifepreserver")
                    }
                }
                
                Section("What is next?") {
                    NavigationLink {
                        UpdatesView()
                    } label: {
                        Label("Upcoming updates", systemImage: "chart.line.uptrend.xyaxis")
                    }

                }
                
                Section("Notifications") {
                    NavigationLink(destination: {
//                        LazyView(NotificationsView())
                        NotificationsView()
                    }) {
                        Label("Notifications", systemImage: "bell")
                    }
                }
                
                Section("Haptic feedback") {
                    Toggle(isOn: .constant(false)) {
                        Label("Turn on", systemImage: "hand.tap")
                    }
                }
                
                Section("Signed in as \(authViewModel.displayName)") {
                    SignOutButton(action: { Task {
                        await authViewModel.signOut()
                    }}, description: "Sign out")
                }
                
                Section {
                    Button(action: {}) {
                        Text("Delete account")
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Account")
        }
        .task {
            await authViewModel.setupAuthStateListener()
        }
    }
}

#Preview {
    AccountView()
        .environment(AuthViewModel())
        .environment(FavouriteViewModel())
}

// MARK: - Containers

fileprivate struct PrivateProfileViewContainer: View {
    var body: some View {
        ProfileView()
    }
}

fileprivate struct UserListingsContainer: View {
    var body: some View {
        UserListingView()
    }
}

fileprivate struct FavouriteListingContainer: View {
    var body: some View {
        FavouriteListingView()
    }
}

fileprivate struct SignOutButton: View {
    let action: () -> Void
    let description: String
    @State private var isSigningOut: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button(role: .destructive, action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isSigningOut = true
                }
                performAfterDelay(0.3) {
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



