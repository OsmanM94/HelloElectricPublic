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
    var selectedVehicleType: VehicleType = .cars
    
    // MARK: - Pagination
    private(set) var hasMoreListings: Bool = true
    private(set) var currentPage: Int = 0
    private let pageSize: Int = 20
    private(set) var isListEmpty: Bool = false
    
    // MARK: - Dependencies
    @ObservationIgnored @Injected(\.listingService) private var listingService
    @ObservationIgnored @Injected(\.supabaseService) private var supabaseService
    
    init()  {
        //print("DEBUG: Did init Listing viewmodel.")
    }
    
    // MARK: - Main actor functions
    @MainActor
    func loadListings(isRefresh: Bool = false, vehicleType: VehicleType) async {
        if isRefresh {
            resetPagination()
        } else {
            guard hasMoreListings else { return }
        }
        
        do {
            let newListings = try await searchItemsFromSupabase(
                vehicleType: vehicleType,
                from: currentPage * pageSize,
                to: currentPage * pageSize + pageSize - 1
            )
            updateListings(with: newListings, isRefresh: isRefresh)
            viewState = newListings.isEmpty ? .empty : .loaded
        } catch {
            print("DEBUG: Error loading listings \(error)")
            viewState = .empty
        }
    }
    
    // Refresh listings
    @MainActor
    func refreshListings(vehicleType: VehicleType) async {
        await loadListings(isRefresh: true, vehicleType: vehicleType)
    }
    
    // MARK: - Helpers
    private func resetPagination() {
        self.currentPage = 0
        self.hasMoreListings = true
    }
    
    private func searchItemsFromSupabase(vehicleType: VehicleType, from: Int, to: Int) async throws -> [Listing] {
        do {
            let query = supabaseService.client
                .from("car_listing")
                .select()
                .in("body_type", values: vehicleType.databaseValues)
                .range(from: from, to: to)
                .order("is_promoted", ascending: false) // Sort promoted first
                .order("created_at", ascending: false)  // Then sort by date
            
            let response: [Listing] = try await query.execute().value
            return response
        } catch {
            print("DEBUG: Failed to load listings from Supabase: \(error)")
            throw error
        }
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
    
    private func loadListings() async throws -> [Listing] {
        let from = currentPage * pageSize
        let to = from + pageSize - 1
        return try await listingService.loadPaginatedListings(from: from, to: to)
    }
    
    private func updateListings(with newListings: [Listing]) {
        if newListings.count < pageSize {
            self.hasMoreListings = false
        }
        
        self.listings = newListings
        self.currentPage += 1
        
        print("DEBUG: Loaded \(newListings.count) listings...")
    }
    
}






////// Helper method to add sample data
//private func loadSampleListings()  {
//    listings = generateMockListings(count: 1000)
//    viewState = .loaded
//}
//
//// Method to generate mock listings
//private func generateMockListings(count: Int) -> [Listing] {
//    let mockUserID = UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000")!
//    
//    return (1...count).map { i in
//        Listing(
//            id: 1,
//            createdAt: Date(),
//            imagesURL: [URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/tesla2.jpg")!,URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/tesla1.jpg")!,URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/tesla3.jpg")!], thumbnailsURL: [URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/tesla2.jpg")!],
//            make: "Tesla",
//            model: "Model S supercharger",
//            bodyType: "SUV",
//            condition: "Used",
//            mileage: 100000,
//            location: "London",
//            yearOfManufacture: "2023",
//            price: 8900,
//            textDescription: "A great electric vehicle with long range.",
//            range: "396 miles",
//            colour: "Red",
//            publicChargingTime: "1 hour",
//            homeChargingTime: "10 hours",
//            batteryCapacity: "100 kWh",
//            powerBhp: "1020",
//            regenBraking: "Yes",
//            warranty: "4 years",
//            serviceHistory: "Full",
//            numberOfOwners: "1",
//            userID: mockUserID
//        )
//    }
//}
