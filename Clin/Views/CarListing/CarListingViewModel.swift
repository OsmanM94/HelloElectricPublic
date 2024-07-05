//
//  CarListingViewModel.swift
//  Clin
//
//  Created by asia on 23/06/2024.
//

import Foundation


@Observable
final class CarListingViewModel {
    var listings: [CarListing] = []
    var state: SharedViewState = .loading
    var showFilterSheet: Bool = false
    var title: String = ""
   
    private let carListingService = CarListingService.shared
    private let supabase = SupabaseService.shared.client
    
    @MainActor
    func fetchListings() async {
        do {
            listings = try await carListingService.fetchListings()
            state = .loaded
        } catch {
            print("Error fetching listings: \(error)")
        }
    }
}
