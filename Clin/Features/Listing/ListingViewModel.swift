//
//  CarListingViewModel.swift
//  Clin
//
//  Created by asia on 23/06/2024.
//
import SwiftUI
import Factory

enum VehicleType: String, CaseIterable {
    case cars = "Cars"
    case vans = "Vans"
    case trucks = "Trucks"
    
    var databaseValues: [String] {
        switch self {
        case .cars:
            return [
                "Convertible",
                "Coupe",
                "Estate",
                "Hatchback",
                "MVP",
                "Pickup",
                "Saloon",
                "SUV"
            ]
        case .vans:
            return ["Van"]
        case .trucks:
            return ["Truck"]
        }
    }
}

@Observable
final class ListingViewModel {
    // MARK: - Enum
    enum ViewState {
        case loading
        case loaded
        case empty
    }
    
    // MARK: - Observable properties
    private(set) var listings: [Listing] = []
    private(set) var viewState: ViewState = .loading
    var isDoubleTap: Bool = false
    
    // MARK: - Filter
    var selectedVehicleType: VehicleType = .cars
    
    // MARK: - Pagination
    private(set) var hasMoreListings: Bool = true
    private(set) var currentPage: Int = 0
    private let pageSize: Int = 20
    private(set) var isListEmpty: Bool = false
    
    // MARK: - Dependencies
    @ObservationIgnored @Injected(\.listingService) private var listingService
    
    init()  {
        print("DEBUG: Did init Listing viewmodel.")
    }
    
    // MARK: - Main actor functions
    @MainActor
    func loadListings(isRefresh: Bool = false) async {
        if isRefresh {
            resetPagination()
        } else {
            guard hasMoreListings else { return }
        }
        
        do {
            let newListings = try await listingService.searchListings(
                vehicleType: self.selectedVehicleType,
                from: currentPage * pageSize,
                to: currentPage * pageSize + pageSize - 1
            )
            updateListings(with: newListings, isRefresh: isRefresh)
            viewState = newListings.isEmpty ? .empty : .loaded
        } catch {
            print("DEBUG: Error loading listings \(error)")
        }
    }
    
    // Refresh listings
    @MainActor
    func refreshListings(vehicleType: VehicleType) async {
        await loadListings(isRefresh: true)
    }
    
    // MARK: - Helpers
    private func resetPagination() {
        self.currentPage = 0
        self.hasMoreListings = true
        self.viewState = .loading
    }
    
    private func updateListings(with newListings: [Listing], isRefresh: Bool) {
        if newListings.count < pageSize {
            self.hasMoreListings = false
        }
        
        if isRefresh {
            self.listings = newListings
        } else {
            self.listings.append(contentsOf: newListings)
        }
        
        self.currentPage += 1
        
        print("DEBUG: \(isRefresh ? "Refreshed" : "Loaded") \(newListings.count) listings...")
    }
}

