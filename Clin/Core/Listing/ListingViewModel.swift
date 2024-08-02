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
    
    @MainActor
    func fetchListings() async {
        do {
            listings = try await listingService.fetchListings()
            viewState = .loaded
        } catch {
            viewState = .error(ListingViewStateMessages.generalError.message)
        }
    }
}
