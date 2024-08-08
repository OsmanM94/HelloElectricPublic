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
    private var currentPage: Int = 0
    private let pageSize: Int = 10
    var hasMoreListings: Bool = true
    
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
        do {
            self.currentPage = 0
            self.hasMoreListings = true // Reset the flag
            let from = currentPage * pageSize
            let to = from + pageSize - 1
            
            let newListings = try await listingService.fetchListings(from: from, to: to)
            if newListings.count < pageSize {
                self.hasMoreListings = false // No more listings to fetch
            }
            self.listings = newListings
            self.currentPage += 1
            
            print("DEBUG1: Refreshing list...")
        } catch {
            viewState = .error(ListingViewStateMessages.generalError.message)
        }
    }
}





