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
    
    // MARK: - Observable properties
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
    private let pageSize: Int = 20
   
   // MARK: - Dependencies
    @ObservationIgnored @Injected(\.listingService) private var listingService
    
    init()  {
        print("DEBUG: Did init Listing viewmodel.")
    }
    
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
    
    // Helper method to add sample data
    private func loadSampleListings()  {
        listings = generateMockListings(count: 1000)
        viewState = .loaded
    }
    
    // Method to generate mock listings
    private func generateMockListings(count: Int) -> [Listing] {
        let mockUserID = UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000")!
        
        return (1...count).map { i in
            Listing(
                id: 1,
                createdAt: Date(),
                imagesURL: [URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/tesla2.jpg")!,URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/tesla1.jpg")!,URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/tesla3.jpg")!], thumbnailsURL: [URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/tesla2.jpg")!],
                make: "Tesla",
                model: "Model S supercharger",
                bodyType: "SUV",
                condition: "Used",
                mileage: 100000,
                location: "London",
                yearOfManufacture: "2023",
                price: 8900,
                textDescription: "A great electric vehicle with long range.",
                range: "396 miles",
                colour: "Red",
                publicChargingTime: "1 hour",
                homeChargingTime: "10 hours",
                batteryCapacity: "100 kWh",
                powerBhp: "1020",
                regenBraking: "Yes",
                warranty: "4 years",
                serviceHistory: "Full",
                numberOfOwners: "1",
                userID: mockUserID
            )
        }
    }
}





