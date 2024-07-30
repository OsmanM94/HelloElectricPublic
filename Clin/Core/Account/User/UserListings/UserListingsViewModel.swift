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
    
    enum UserListingsViewStateMessages: String, Error {
        case generalError = "An error occurred. Please try again."
        case noAuthUserFound = "No authenticated user found."
       
        var message: String {
            return self.rawValue
        }
    }
    
    var userActiveListings: [Listing] = []
    var viewState: ViewState = .empty
        
    @MainActor
    func fetchUserListings() async {
        do {
            guard let user = try? await SupabaseService.shared.client.auth.session.user else {
                viewState = .error(UserListingsViewStateMessages.generalError.message)
                return
            }
            userActiveListings = try await ListingService.shared.fetchUserListings(userID: user.id)
            
            viewState = .loaded
        } catch {
            viewState = .error(UserListingsViewStateMessages.noAuthUserFound.message)
        }
    }
    
}
