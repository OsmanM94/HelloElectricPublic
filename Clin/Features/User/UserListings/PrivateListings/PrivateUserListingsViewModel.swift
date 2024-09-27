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
        case refreshSuccess(String)
        case success
        case error(String)
    }
    
    // MARK: - Observable properties
    // Do not delete any of these properties.
    var listingToDelete: Listing?
    var selectedListing: Listing?
    
    var showRefreshRestrictionAlert: Bool = false
    var refreshRestrictionMessage: String = ""
    
    var showingEditView: Bool = false
    var showDeleteAlert: Bool = false
    var showRefreshAlert: Bool = false
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
                viewState = .error(MessageCenter.MessageType.noAuthUserFound.message)
                return
            }
            
            let listings = try await listingService.loadUserListings(userID: currentUser.id)
            
            self.listings = listings
            self.viewState = listings.isEmpty ? .empty : .success
            
        } catch {
            self.viewState = .error(MessageCenter.MessageType.generalError.message)
        }
    }
    
    @MainActor
    func refreshListing(_ listing: Listing) async {
        guard canRefreshListing(listing) else {
            showRefreshRestrictionAlert(for: listing)
            return
        }
        
        self.viewState = .loading
        do {
            guard let id = listing.id else {
                self.viewState = .error(MessageCenter.MessageType.generalError.message)
                return
            }
            try await listingService.refreshListings(id: id)
                        
            self.viewState = .refreshSuccess(MessageCenter.MessageType.refreshSuccess.message)
        } catch {
            self.viewState = .error(MessageCenter.MessageType.generalError.message)
        }
    }
    
    @MainActor
    func canRefreshListing(_ listing: Listing) -> Bool {
        let calendar = Calendar.current
        let daysSinceCreation = calendar.dateComponents([.day], from: listing.createdAt, to: Date()).day ?? 0
        return daysSinceCreation >= 30 // 30 days restriction
    }
    
    @MainActor
    func deleteListing(_ listing: Listing) async {
        guard let id = listing.id else {
            self.viewState = .error(MessageCenter.MessageType.generalError.message)
            return
        }
        
        do {
            try await listingService.deleteListing(at: id)
        } catch {
            self.viewState = .error(MessageCenter.MessageType.generalError.message)
        }
    }
    
    // MARK: - Functions
    func showRefreshRestrictionAlert(for listing: Listing) {
        let nextRefreshDate = Calendar.current.date(byAdding: .day, value: 30, to: listing.createdAt)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none

            refreshRestrictionMessage = """
            
            You can refresh your listing once every 30 days.
            
            Alternatively, consider promoting your listing for better reach.

            Your listing was last refreshed on \(dateFormatter.string(from: listing.createdAt)).
            You'll be able to refresh it again on \(dateFormatter.string(from: nextRefreshDate ?? Date.now)).

            Thank you
            """
            showRefreshRestrictionAlert = true
        }
}

