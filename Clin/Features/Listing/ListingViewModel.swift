//
//  CarListingViewModel.swift
//  Clin
//
//  Created by asia on 23/06/2024.
//
import SwiftUI
import Factory

final class ListingViewModel: ObservableObject {
    enum ViewState {
        case loading
        case loaded
    }
    
    @Published private(set) var listings: [Listing] = []
    @Published private(set) var viewState: ViewState = .loading
    
    @Published var showFilterSheet: Bool = false
    @Published var isDoubleTap: Bool = false
    @Published private(set) var hasMoreListings: Bool = true
    private(set) var currentPage: Int = 0
    private(set) var lastRefreshTime: Date? = nil
    private let pageSize: Int = 10
    private let refreshCooldown: TimeInterval = 10
   
    init() {
        print("DEBUG: Did init ListingViewModel")
    }
    
    @Injected(\.listingService) private var listingService
    
    @MainActor
    func fetchListings() async {
        guard hasMoreListings else { return }
        
        let from = currentPage * pageSize
        let to = from + pageSize - 1
        
        do {
            let newListings = try await listingService.fetchPaginatedListings(from: from, to: to)
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
            
            let newListings = try await listingService.fetchPaginatedListings(from: from, to: to)
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





