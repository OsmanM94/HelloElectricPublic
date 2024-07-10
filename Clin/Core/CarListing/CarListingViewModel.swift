//
//  CarListingViewModel.swift
//  Clin
//
//  Created by asia on 23/06/2024.
//

import Foundation

@Observable
final class CarListingViewModel {
    enum CarListingViewState {
        case loading
        case loaded
    }
    
    var listings: [CarListing] = []
    var viewState: CarListingViewState = .loading
    var showFilterSheet: Bool = false
    
    private let carListingService = DatabaseService.shared
    private let supabase = SupabaseService.shared.client
    
    @MainActor
    func fetchListings() async {
        do {
            listings = try await carListingService.fetchListings()
            viewState = .loaded
        } catch {
            print("Error fetching listings: \(error)")
        }
    }
}
