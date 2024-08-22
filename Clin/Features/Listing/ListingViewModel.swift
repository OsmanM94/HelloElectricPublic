//
//  CarListingViewModel.swift
//  Clin
//
//  Created by asia on 23/06/2024.
//
import SwiftUI
import Factory

@Observable
final class ListingViewModel {
    enum ViewState {
        case loading
        case loaded
    }
    
    private(set) var listings: [Listing] = []
    private(set) var viewState: ViewState = .loading
    
    var showFilterSheet: Bool = false
    var isDoubleTap: Bool = false
    private(set) var hasMoreListings: Bool = true
    private(set) var currentPage: Int = 0
    private(set) var lastRefreshTime: Date? = nil
    private let pageSize: Int = 10
    private let refreshCooldown: TimeInterval = 10
   
    @ObservationIgnored
    @Injected(\.listingService) private var listingService
    
    init() {
        print("DEBUG: Did init Listing viewmodel.")
    }
    
    @MainActor
    func fetchListings() async {
        guard hasMoreListings else { return }
        
        let from = currentPage * pageSize
        let to = from + pageSize - 1
        
        do {
            let newListings = try await listingService.loadPaginatedListings(from: from, to: to)
            if newListings.count < pageSize {
                self.hasMoreListings = false // No more listings to fetch
            }
            withAnimation {
                listings.append(contentsOf: newListings)
            }
            viewState = .loaded
            self.currentPage += 1
            
            print("DEBUG: Fetching 10 listings...")
        } catch {
            print("DEBUG: Error fetching listings \(error)")
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
            
            let newListings = try await listingService.loadPaginatedListings(from: from, to: to)
            if newListings.count < pageSize {
                self.hasMoreListings = false
            }
            self.listings = newListings
            self.currentPage += 1
           
            lastRefreshTime = Date()
            print("DEBUG: Refreshing list...")
        } catch {
            print("DEBUG: Error refreshing listings \(error)")
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





