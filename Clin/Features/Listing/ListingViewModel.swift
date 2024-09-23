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

enum QuickFilter: String, CaseIterable, Identifiable {
    case all
    case cheapest
    case expensive
    case lowestMileage
    case longestRange
    case highestPower

    var id: String { self.rawValue }

    var databaseValue: String? {
        switch self {
        case .all: return nil
        case .cheapest: return "price"
        case .expensive: return "price"
        case .lowestMileage: return "mileage"
        case .longestRange: return "range"
        case .highestPower: return "power_bhp"
        }
    }

    var displayName: String {
        switch self {
        case .all: return "All"
        case .cheapest: return "Cheapest"
        case .expensive: return "Most Expensive"
        case .lowestMileage: return "Lowest Mileage"
        case .longestRange: return "Longest Range"
        case .highestPower: return "Highest Power"
        }
    }

    var ascending: Bool {
        switch self {
        case .highestPower: return false
        case .longestRange: return false
        case .expensive: return false
        default: return true
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
    
    // MARK: - Filter
    var selectedVehicleType: VehicleType = .cars {
        didSet {
            if oldValue != selectedVehicleType {
                quickFilter = .all // Reset quickFilter when vehicle type changes
                Task { await refreshListings(resetState: true) }
            }
        }
    }
    
    var quickFilter: QuickFilter = .all {
        didSet {
            if oldValue != quickFilter {
                Task { await refreshListings(resetState: true) }
            }
        }
    }
    
    // MARK: - Pagination
    private(set) var hasMoreListings: Bool = true
    private(set) var currentPage: Int = 0
    private let pageSize: Int = 20
    private(set) var isListEmpty: Bool = false
    
    // MARK: - Dependencies
    @ObservationIgnored @Injected(\.listingService) private var listingService
    
    init() {
        print("DEBUG: Did init listing viewmodel.")
    }
    
    // MARK: - Main actor functions
    
    @MainActor
    func loadListings() async {
        guard hasMoreListings else { return }
        
        do {
            let newListings: [Listing]
            let vehicleTypeFilter = selectedVehicleType.databaseValues
            
            if quickFilter != .all, let orderBy = quickFilter.databaseValue {
                newListings = try await listingService.loadFilteredListings(
                    vehicleType: vehicleTypeFilter,
                    orderBy: orderBy,
                    ascending: quickFilter.ascending,
                    from: currentPage * pageSize,
                    to: currentPage * pageSize + pageSize - 1
                )
            } else {
                newListings = try await listingService.loadListingsByVehicleType(
                    type: vehicleTypeFilter,
                    column: "body_type",
                    from: currentPage * pageSize,
                    to: currentPage * pageSize + pageSize - 1
                )
            }
            
            updateListings(with: newListings, isRefresh: currentPage == 0)
            viewState = newListings.isEmpty ? .empty : .loaded
        } catch {
            print("DEBUG: Error loading listings \(error)")
            viewState = .empty
        }
    }
    
    @MainActor
    func refreshListings(resetState: Bool) async {
        resetPagination()
        if resetState {
            viewState = .loading
        }
        await loadListings()
    }
    
    // MARK: - Helpers
    private func resetPagination() {
        self.currentPage = 0
        self.hasMoreListings = true
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

