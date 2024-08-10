//
//  CarListingViewModel.swift
//  Clin
//
//  Created by asia on 23/06/2024.
//

import Foundation

@Observable
final class ListingViewModel {
    enum ListingViewState {
        case loading
        case loaded
        case error(String)
    }
    
    enum ListingViewStateMessages: String, Error {
        case generalError = "An error occurred. Please try again."
        case noAuthUserFound = "No authenticated user found."
        
        var message: String {
            return self.rawValue
        }
    }
    private let listingService: ListingServiceProtocol
    
    init(listingService: ListingServiceProtocol) {
        self.listingService = listingService
    }
    
    private(set) var listings: [Listing] = []
    private(set) var viewState: ListingViewState = .loading
    
    var showFilterSheet: Bool = false
    
    private(set) var hasMoreListings: Bool = true
    private var currentPage: Int = 0
    private let pageSize: Int = 10
    private var lastRefreshTime: Date? = nil
    private let refreshCooldown: TimeInterval = 10
    
    @MainActor
    func fetchListings() async {
        guard hasMoreListings else { return }
        
        let from = currentPage * pageSize
        let to = from + pageSize - 1
        
        do {
            let newListings = try await listingService.fetchListings(from: from, to: to)
            if newListings.count < pageSize {
                self.hasMoreListings = false // No more listings to fetch
            }
            listings.append(contentsOf: newListings)
            viewState = .loaded
            self.currentPage += 1
            
            print("DEBUG: Fetching 10 listings...")
        } catch {
            viewState = .error(ListingViewStateMessages.generalError.message)
        }
    }
    
    @MainActor
    func refreshListings() async {
        if !canRefresh() {
            print("DEBUG: Refreshing cooldown is active...")
            return
        }
    
        do {
            self.currentPage = 0
            self.hasMoreListings = true
            let from = currentPage * pageSize
            let to = from + pageSize - 1
            
            let newListings = try await listingService.fetchListings(from: from, to: to)
            if newListings.count < pageSize {
                self.hasMoreListings = false
            }
            self.listings = newListings
            self.currentPage += 1
            
            lastRefreshTime = Date()
            print("DEBUG: Refreshing list...")
        } catch {
            viewState = .error(ListingViewStateMessages.generalError.message)
        }
    }
    
    private func canRefresh() -> Bool {
        if let lastRefreshTime = lastRefreshTime {
            let timeSinceLastRefresh = Date().timeIntervalSince(lastRefreshTime)
            return timeSinceLastRefresh >= refreshCooldown
        }
        return true
    }
}





