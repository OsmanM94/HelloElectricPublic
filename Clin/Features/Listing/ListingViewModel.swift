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
    // MARK: - Enum
    enum ViewState {
        case loading
        case loaded
    }
    
    // MARK: - Misc
    private(set) var listings: [Listing] = []
    private(set) var viewState: ViewState = .loading
    var showFilterSheet: Bool = false
    var isDoubleTap: Bool = false
    
    // MARK: - Refreshable actions
    private let refreshCooldown: TimeInterval = 10
    private(set) var lastRefreshTime: Date? = nil
    
    // MARK: - Pagination
    private(set) var hasMoreListings: Bool = true
    private(set) var currentPage: Int = 0
    private let pageSize: Int = 10
   
   // MARK: - Dependencies
    @ObservationIgnored @Injected(\.listingService) private var listingService
    
    init() {
        print("DEBUG: Did init Listing viewmodel.")
    }
    
    // MARK: - Main actor functions
//    @MainActor
//    func loadListings() async {
//        guard hasMoreListings else { return }
//        
//        let from = currentPage * pageSize
//        let to = from + pageSize - 1
//        
//        do {
//            let newListings = try await listingService.loadPaginatedListings(from: from, to: to)
//            if newListings.count < pageSize {
//                self.hasMoreListings = false
//            }
//            withAnimation {
//                listings.append(contentsOf: newListings)
//            }
//            viewState = .loaded
//            self.currentPage += 1
//            
//            print("DEBUG: Loading 10 listings...")
//        } catch {
//            print("DEBUG: Error loading listings \(error)")
//        }
//    }
//    
//    @MainActor
//    func refreshListings() async {
//        if !canRefresh() {
//            print("DEBUG: Refreshing cooldown is active...")
//            return
//        }
//       
//        do {
//            self.currentPage = 0
//            self.hasMoreListings = true
//            let from = currentPage * pageSize
//            let to = from + pageSize - 1
//            
//            let newListings = try await listingService.loadPaginatedListings(from: from, to: to)
//            if newListings.count < pageSize {
//                self.hasMoreListings = false
//            }
//            self.listings = newListings
//            self.currentPage += 1
//           
//            lastRefreshTime = Date()
//            print("DEBUG: Refreshing list...")
//        } catch {
//            print("DEBUG: Error refreshing listings \(error)")
//        }
//    }
//    
//    // MARK: - Helpers
//    private func canRefresh() -> Bool {
//        if let lastRefreshTime = lastRefreshTime {
//            let timeSinceLastRefresh = Date().timeIntervalSince(lastRefreshTime)
//            return timeSinceLastRefresh >= refreshCooldown
//        }
//        return true
//    }
    
    @MainActor
    func loadListings(isRefresh: Bool = false) async {
        if isRefresh {
            guard canRefresh() else {
                print("DEBUG: Refreshing cooldown is active...")
                return
            }
            resetPagination()
        } else {
            guard hasMoreListings else { return }
        }
        
        do {
            let newListings = try await loadListings()
            updateListings(with: newListings, isRefresh: isRefresh)
        } catch {
            print("DEBUG: Error loading listings \(error)")
        }
    }
    
    @MainActor
    func refreshListings() async {
        await loadListings(isRefresh: true)
    }
    
    // MARK: - Helpers
    private func canRefresh() -> Bool {
        if let lastRefreshTime = lastRefreshTime {
            let timeSinceLastRefresh = Date().timeIntervalSince(lastRefreshTime)
            return timeSinceLastRefresh >= refreshCooldown
        }
        return true
    }
    
    private func resetPagination() {
        self.currentPage = 0
        self.hasMoreListings = true
    }
    
    private func loadListings() async throws -> [Listing] {
        let from = currentPage * pageSize
        let to = from + pageSize - 1
        return try await listingService.loadPaginatedListings(from: from, to: to)
    }
    
    private func updateListings(with newListings: [Listing], isRefresh: Bool) {
        if newListings.count < pageSize {
            self.hasMoreListings = false
        }
        
        if isRefresh {
            self.listings = newListings
        } else {
            withAnimation {
                self.listings.append(contentsOf: newListings)
            }
            viewState = .loaded
        }
        
        self.currentPage += 1
        if isRefresh {
            lastRefreshTime = Date()
        }
        
        print("DEBUG: \(isRefresh ? "Refreshing" : "Loading") \(newListings.count) listings...")
    }
}





