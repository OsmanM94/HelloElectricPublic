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
    
    init() {
        print("DEBUG: Did init user listings viewmodel")
    }
    
    // MARK: - Main actor functions
    @MainActor
    func loadListings() async {
        do {
            guard let user = try await listingService.getCurrentUser() else {
                viewState = .error(MessageCenter.MessageType.noAuthUserFound.message)
                return
            }
            
            let listings = try await listingService.loadUserListings(userID: user.id)
            
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
        
        self.viewState = .loading
        
        do {
            // Delete the listing from the database
            try await listingService.deleteListing(at: id)
            
            // Delete associated main images and thumbnails from storage
            let allImageUrls = listing.imagesURL + listing.thumbnailsURL
            let imagePaths = allImageUrls.compactMap { extractImagePath($0) }
            
            if !imagePaths.isEmpty {
                try await listingService.deleteImagesFromStorage(from: "car_images", path: imagePaths)
            }
            
            // Remove the deleted listing from the local array
            if let index = listings.firstIndex(where: { $0.id == id }) {
                listings.remove(at: index)
            }
            
            self.viewState = .success
        } catch {
            self.viewState = .error(MessageCenter.MessageType.generalError.message)
        }
    }
    
    private func extractImagePath(_ imageUrl: URL) -> String? {
        let bucket = "car_images"
        
        guard let pathComponents = URLComponents(url: imageUrl, resolvingAgainstBaseURL: false)?.path.components(separatedBy: "/"),
              let carImagesIndex = pathComponents.firstIndex(of: bucket),
              carImagesIndex < pathComponents.count - 1 else {
            
            print("DEBUG: Failed to extract image path from URL: \(imageUrl)")
            return nil
        }
        
        let folderPath = pathComponents[carImagesIndex + 1] // This should be the user ID
        let fileName = pathComponents.last ?? ""
        
        return "\(folderPath)/\(fileName)"
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
            """
            showRefreshRestrictionAlert = true
        }
}

