//
//  UserListingViewModel.swift
//  Clin
//
//  Created by asia on 31/07/2024.
//
import Foundation
import Factory

@Observable
final class PrivateUserListingsViewModel {
    // MARK: - Enum
    enum ViewState: Equatable {
        case empty
        case loading
        case success
        case error(String)
    }
    
    // MARK: - Observable properties
    // Do not delete any of these properties.
    var listingToDelete: Listing?
    var selectedListing: Listing?
    
    var showingEditView: Bool = false
    var showDeleteAlert: Bool = false
    private(set) var listings: [Listing] = []
    private(set) var viewState: ViewState = .loading
    
    // MARK: - Dependencies
    @ObservationIgnored @Injected(\.listingService) private var listingService
    @ObservationIgnored @Injected(\.supabaseService) private var supabaseService
    
    init() {
        print("DEBUG: Did init user listings viewmodel")
    }
    
    // MARK: - Main actor functions
    @MainActor
    func loadListings() async {
        do {
            guard let currentUser = try? await supabaseService.client.auth.session.user else {
                viewState = .error(AppError.ErrorType.noAuthUserFound.message)
                return
            }
            
            let listings = try await listingService.loadUserListings(userID: currentUser.id)
            
            self.listings = listings
            self.viewState = listings.isEmpty ? .empty : .success
            
        } catch {
            self.viewState = .error(AppError.ErrorType.generalError.message)
        }
    }
    
    @MainActor
    func deleteListing(_ listing: Listing) async {
        do {
            guard let id = listing.id else {
                self.viewState = .error(AppError.ErrorType.noAuthUserFound.message)
                return
            }
            try await listingService.deleteListing(at: id)
        } catch {
            self.viewState = .error(AppError.ErrorType.generalError.message)
        }
    }
}

