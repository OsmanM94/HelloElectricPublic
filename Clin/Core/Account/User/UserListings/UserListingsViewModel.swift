//
//  UserListings.swift
//  Clin
//
//  Created by asia on 25/06/2024.
//

import Foundation


@Observable
final class UserListingsViewModel {
    enum ViewState {
        case empty
        case loaded
        case error(String)
    }
    
    var userActiveListings: [Listing] = []
    var viewState: ViewState = .empty
    
    private var userID: UUID?
    
    @MainActor
    func fetchUserListings() async {
        do {
            guard let user = try? await SupabaseService.shared.client.auth.session.user else {
                print("No authenticated user found")
                return
            }
            
            userID = user.id
            userActiveListings = try await ListingService.shared.fetchUserListings(userID: user.id)
            
            viewState = .loaded
        } catch {
            viewState = .error("Error retrieving listings.")
        }
        updateViewState()
    }
    
    private func updateViewState() {
        if userActiveListings.isEmpty {
            viewState = .empty
        } else {
            viewState = .loaded
        }
    }
}
