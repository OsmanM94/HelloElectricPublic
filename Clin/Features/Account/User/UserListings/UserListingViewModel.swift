//
//  UserListingViewModel.swift
//  Clin
//
//  Created by asia on 31/07/2024.
//
import Foundation
import Factory

final class UserListingViewModel: ObservableObject {
    enum ViewState: Equatable {
        case empty
        case success
        case error(String)
    }
    
    enum UserListingsViewStateMessages: String, Error {
        case generalError = "An error occurred. Please try again."
        case noAuthUserFound = "No authenticated user found."
        case deleteSuccess = "Listing deleted succesfully."
        var message: String {
            return self.rawValue
        }
    }
    
    @Published var listingToDelete: Listing?
    @Published var selectedListing: Listing?
    @Published var showingEditView: Bool = false
    @Published var showDeleteAlert: Bool = false
    @Published private(set) var userActiveListings: [Listing] = []
    @Published private(set) var viewState: ViewState = .empty
    
    @Injected(\.listingService) private var listingService
    @Injected(\.supabaseService) private var supabaseService
    
    init() {
        print("DEBUG: Did init UserListingViewModel")
    }
    
    @MainActor
    func fetchUserListings() async {
        do {
            guard let user = try? await supabaseService.client.auth.session.user else {
                viewState = .error(UserListingsViewStateMessages.generalError.message)
                return
            }
            
            self.userActiveListings = try await listingService.fetchUserListings(userID: user.id)
            viewState = .success
        } catch {
            viewState = .error(UserListingsViewStateMessages.noAuthUserFound.message)
        }
        checkViewState()
    }
    
    @MainActor
    func deleteUserListing(_ listing: Listing) async {
        do {
            guard let id = listing.id else {
                viewState = .error(UserListingsViewStateMessages.noAuthUserFound.message)
                return
            }
            try await listingService.deleteListing(at: id)
        } catch {
            viewState = .error(UserListingsViewStateMessages.generalError.message)
        }
    }

    private func checkViewState() {
        if userActiveListings.isEmpty {
            viewState = .empty
        }
    }
}

