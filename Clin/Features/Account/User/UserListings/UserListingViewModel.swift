//
//  UserListingViewModel.swift
//  Clin
//
//  Created by asia on 31/07/2024.
//
import Foundation
import Factory

@Observable
final class UserListingViewModel {
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
    
    var listingToDelete: Listing?
    var selectedListing: Listing?
    var showingEditView: Bool = false
    var showDeleteAlert: Bool = false
    private(set) var userActiveListings: [Listing] = []
    private(set) var viewState: ViewState = .empty
    
    @ObservationIgnored
    @Injected(\.listingService) private var listingService
    @ObservationIgnored
    @Injected(\.supabaseService) private var supabaseService
    

    @MainActor
    func fetchUserListings() async {
        do {
            guard let currentUser = try? await supabaseService.client.auth.session.user else {
                viewState = .error(UserListingsViewStateMessages.generalError.message)
                return
            }
            
            self.userActiveListings = try await listingService.fetchUserListings(userID: currentUser.id)
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

