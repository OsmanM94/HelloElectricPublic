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
    }
    
    var listings: [Listing] = []
    var viewState: ListingViewState = .loading
    var showFilterSheet: Bool = false
    
    private let listingService = ListingService.shared
    private let supabase = SupabaseService.shared.client
    
    @MainActor
    func fetchListings() async {
        do {
            listings = try await listingService.fetchListings()
            viewState = .loaded
        } catch {
            print("Error fetching listings: \(error)")
        }
    }
}
