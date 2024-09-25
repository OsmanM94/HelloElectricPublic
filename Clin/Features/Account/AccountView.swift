//
//  SettingsView.swift
//  Clin
//
//  Created by asia on 22/06/2024.
//

import SwiftUI

struct AccountView: View {
    @Environment(AccountViewModel.self) private var accountViewModel
   
    @Bindable var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                switch authViewModel.viewState {
                case .unauthenticated:
                    AuthenticationView()
                  
                case .loading:
                    CustomProgressView(message: "Loading...")
                    
                case .authenticated:
                    accountContent
                    
                case .error(let message):
                    ErrorView(
                        message: message,
                        refreshMessage: "Try again",
                        retryAction: { authViewModel.resetState() },
                        systemImage: "xmark.circle.fill")
                }
            }
            .animation(.easeInOut(duration: 0.3), value: authViewModel.viewState)
        }
    }
    
    // MARK: - Main content
    private var accountContent: some View {
        Form {
            manageSection
            legalSection
            supportSection
            aboutUsSection
            whatsNextSection
            notificationsSection
            faceIDSection
            hapticSection
            
            signOutSection
            deleteAccountSection
            
            appVersionSection
        }
        .navigationTitle("Account")
        .showStandardAlert(
            isPresented: $authViewModel.showDeleteAlert,
            message: "Are you sure you want to delete your account? This action cannot be undone.",
            title: "Delete Confirmation",
            deleteAction: { await authViewModel.deleteAccount() }
        )
    }
    
    // MARK: Sections
    private var manageSection: some View {
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
    }
    
    private var legalSection: some View {
        Section("Legal") {
            NavigationLink {
                LazyView(LegalView())
            } label: {
                Label("Documents", systemImage: "doc.text")
            }
        }
    }
    
    private var supportSection: some View {
        Section("Support") {
            NavigationLink {
                LazyView(SupportCenterView())
            } label: {
                Label("Support", systemImage: "lifepreserver")
            }
        }
    }
    
    private var aboutUsSection: some View {
        Section("Our mission") {
            NavigationLink {
                LazyView(AboutUsView())
            } label: {
                Label("About us", systemImage: "network")
            }
        }
    }
    
    private var whatsNextSection: some View {
        Section("What's next?") {
            NavigationLink {
                UpdatesView()
            } label: {
                Label("Upcoming updates", systemImage: "chart.line.uptrend.xyaxis")
            }

        }
    }
    
    private var notificationsSection: some View {
        Section("Notifications") {
            NavigationLink(destination: {
                LazyView(NotificationsView())
            }) {
                Label("Notifications", systemImage: "bell")
            }
        }
    }
    
    private var faceIDSection: some View {
        Section(footer: Text("Enable FaceID for secure and convenient authentication every time you open the app.")) {
            Toggle(isOn: Bindable(accountViewModel).faceIDisEnabled) {
                Label("FaceID", systemImage: "faceid")
            }
            .disabled(!accountViewModel.faceID.isBiometricsAvailable)
        }
    }
    
    private var hapticSection: some View {
        Section {
            Toggle(isOn: Bindable(accountViewModel).navigationHaptic) {
                Label("Haptic Feedback", systemImage: "hand.tap")
            }
        }
    }
    
    private var signOutSection: some View {
        Section("Signed in as \(authViewModel.displayName)") {
            Button {
                Task { await authViewModel.signOut() }
            } label: {
                Text("Sign out")
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var deleteAccountSection: some View {
        Section(footer: Text("All associated data will be deleted.")) {
            Button(action: {
                authViewModel.showDeleteAlert.toggle()
            }) {
                Text("Delete account")
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var appVersionSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text(AppConstants.App.version)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    AccountView(authViewModel: AuthViewModel())
        .environment(AuthViewModel())
        .environment(FavouriteViewModel())
        .environment(AccountViewModel())
}

// MARK: - Containers

fileprivate struct PrivateProfileViewContainer: View {
    var body: some View {
        ProfileView()
    }
}

fileprivate struct UserListingsContainer: View {
    var body: some View {
        PrivateUserListingsView()
    }
}

fileprivate struct FavouriteListingContainer: View {
    var body: some View {
        FavouriteListingView()
    }
}




