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

enum ListingFilter: String, CaseIterable {
    case all = "All"
    case cheapest = "Cheapest"
    case expensive = "Most Expensive"
    case lowestMileage = "Lowest Mileage"
    case longestRange = "Longest Range"
    case highestPower = "Highest Power"

    var orderBy: String {
        switch self {
        case .all: return "refreshed_at"
        case .cheapest, .expensive: return "price"
        case .lowestMileage: return "mileage"
        case .longestRange: return "range"
        case .highestPower: return "power_bhp"
        }
    }

    var ascending: Bool {
        switch self {
        case .all, .expensive, .longestRange, .highestPower: return false
        case .cheapest, .lowestMileage: return true
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
    var listings: [Listing] = []
    private(set) var viewState: ViewState = .loading
    
    // MARK: - Filter
    var listingFilter: ListingFilter = .all {
        didSet {
            if oldValue != listingFilter {
                Task { await refreshListings() }
            }
        }
    }
    
    var selectedVehicleType: VehicleType = .cars {
        didSet {
            if oldValue != selectedVehicleType {
                Task { await refreshListings() }
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
    
    // MARK: - Main actor functions
    
    @MainActor
    func loadListings() async {
        guard hasMoreListings else { return }
        
        do {
            let newListings: [Listing]
            if listingFilter == .all {
                newListings = try await listingService.loadListingsByVehicleType(
                    type: selectedVehicleType.databaseValues,
                    column: "body_type",
                    from: currentPage * pageSize,
                    to: (currentPage + 1) * pageSize - 1
                )
            } else {
                newListings = try await listingService.loadFilteredListings(
                    vehicleType: selectedVehicleType.databaseValues,
                    orderBy: listingFilter.orderBy,
                    ascending: listingFilter.ascending,
                    from: currentPage * pageSize,
                    to: (currentPage + 1) * pageSize - 1
                )
            }
            
            updateListings(with: newListings)
        } catch {
            print("Error loading listings.")
        }
    }
       
       @MainActor
       func refreshListings() async {
           listings.removeAll()
           currentPage = 0
           hasMoreListings = true
           viewState = .loading
           await loadListings()
       }
    
    // MARK: - Helpers
    private func resetPagination() {
        self.currentPage = 0
        self.hasMoreListings = true
    }
        
    private func updateListings(with newListings: [Listing]) {
        if newListings.count < pageSize {
            hasMoreListings = false
        }
        
        listings.append(contentsOf: newListings)
        currentPage += 1
        
        viewState = listings.isEmpty ? .empty : .loaded
    }
    
     func filterSystemImage(for filter: ListingFilter) -> String {
        switch filter {
        case .all:
            return "list.bullet"
        case .cheapest:
            return "lirasign.circle"
        case .expensive:
            return "lirasign.circle.fill"
        case .lowestMileage:
            return "speedometer"
        case .longestRange:
            return "battery.100"
        case .highestPower:
            return "bolt.fill"
        }
    }
}

