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
    
    @MainActor
    func fetchListings() async {
        let from = currentPage * pageSize
        let to = from + pageSize - 1
        
        do {
            let newListings = try await listingService.fetchListings(from: from, to: to)
            listings.append(contentsOf: newListings)
            viewState = .loaded
            self.currentPage += 1
            
            print("DEBUG2: Fetching 10 more listings...")
        } catch {
            viewState = .error(ListingViewStateMessages.generalError.message)
        }
    }
    
    @MainActor
    func refreshListings() async {
        do {
            self.currentPage = 0
            let from = currentPage * pageSize
            let to = from + pageSize - 1
            
            let newListings = try await listingService.fetchListings(from: from, to: to)
            self.listings = newListings
            self.currentPage += 1
            
            print("DEBUG2: Refreshing list...")
        } catch {
            viewState = .error(ListingViewStateMessages.generalError.message)
        }
    }
}





