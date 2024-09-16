//
//  SettingsView.swift
//  Clin
//
//  Created by asia on 22/06/2024.
//

import SwiftUI

struct AccountView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(AccountViewModel.self) private var accountViewModel
    
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
                
                Section("What's next?") {
                    NavigationLink {
                        UpdatesView()
                    } label: {
                        Label("Upcoming updates", systemImage: "chart.line.uptrend.xyaxis")
                    }

                }
                
                Section("Notifications") {
                    NavigationLink(destination: {
                        LazyView(NotificationsView())
                    }) {
                        Label("Notifications", systemImage: "bell")
                    }
                }
                
                Section {
                    Toggle(isOn: Bindable(accountViewModel).navigationHaptic) {
                        Label("Haptic Feedback", systemImage: "hand.tap")
                    }
                }
                
                Section("Signed in as \(authViewModel.displayName)") {
                    Button {
                        Task { await authViewModel.signOut() }
                    } label: {
                        Text("Sign out")
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                Section {
                    Button(action: {}) {
                        Text("Delete account")
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(AppConstants.App.version)
                            .foregroundStyle(.secondary)
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




