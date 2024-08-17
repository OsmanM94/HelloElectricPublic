//
//  SettingsView.swift
//  Clin
//
//  Created by asia on 22/06/2024.
//

import SwiftUI

struct AccountView: View {
    @Environment(AuthViewModel.self) private var authViewModel
 
    let imageManager: ImageManager
    let prohibitedWordService: ProhibitedWordsService
    let listingService: ListingService
    let httpDownloader: HTTPDataDownloader
    
    init(imageManager: ImageManager, prohibitedWordService: ProhibitedWordsService, listingService: ListingService, httpDownloader: HTTPDataDownloader) {
        self.imageManager = imageManager
        self.prohibitedWordService = prohibitedWordService
        self.listingService = listingService
        self.httpDownloader = httpDownloader
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Manage") {
                    NavigationLink("Profile", destination: {
                        ProfileView(viewModel: ProfileViewModel(imageManager: imageManager, prohibitedWordsService: prohibitedWordService))
                    })
                    NavigationLink("My listings", destination: {
                        UserListingView(viewModel: UserListingViewModel(listingService: listingService), listingService: listingService, imageManager: imageManager, prohibitedWordsService: prohibitedWordService, httpDownloader: httpDownloader)
                    })
                    NavigationLink("Saved", destination: {
                        FavouriteListingView()
                    })
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
                
                Section("Signed in as \(authViewModel.displayName) ") {
                    SignOutButton(action: { Task {
                        await authViewModel.signOut() } }, description: "Sign out")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await authViewModel.setupAuthStateListener()
        }
    }
}

#Preview {
    AccountView(
        imageManager: ImageManager(),
        prohibitedWordService: ProhibitedWordsService(),
        listingService: ListingService(databaseService: DatabaseService()), httpDownloader: HTTPDataDownloader()
    )
    .environment(AuthViewModel())
    .environmentObject(FavouriteViewModel(favouriteService: MockFavouriteService())
    )
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



