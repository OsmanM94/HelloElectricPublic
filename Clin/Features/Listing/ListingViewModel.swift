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
    
    var listings: [Listing] = []
    var viewState: ListingViewState = .loading
    
    var showFilterSheet: Bool = false
    var hasMoreListings: Bool = true
    
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
            
            print("DEBUG1: Fetching 10 listings...")
        } catch {
            viewState = .error(ListingViewStateMessages.generalError.message)
        }
    }
    
    @MainActor
    func refreshListings() async {
//        if let lastRefreshTime = lastRefreshTime {
//            let timeSinceLastRefresh = Date().timeIntervalSince(lastRefreshTime)
//            if timeSinceLastRefresh < refreshCooldown {
//                return
//            }
//        }
//        if let lastRefreshTime = lastRefreshTime {
//            let timeSinceLastRefresh = Date().timeIntervalSince(lastRefreshTime)
//            if timeSinceLastRefresh < refreshCooldown {
//                let elapsedTimeString = timeElapsedString(since: lastRefreshTime)
//                print("DEBUG: Refresh attempted too soon, please wait.")
//                viewState = .error("Last refreshed \(elapsedTimeString). Please wait 10 seconds before refreshing again.")
//                return
//            }
//        }
        do {
            self.currentPage = 0
            self.hasMoreListings = true
            let from = currentPage * pageSize
            let to = from + pageSize - 1
            
            let newListings = try await listingService.fetchListings(from: from, to: to)
            if newListings.count < pageSize {
                self.hasMoreListings = false // No more listings to fetch
            }
            self.listings = newListings
            self.currentPage += 1
            
//            lastRefreshTime = Date()
            print("DEBUG1: Refreshing list...")
        } catch {
            viewState = .error(ListingViewStateMessages.generalError.message)
        }
    }
}





