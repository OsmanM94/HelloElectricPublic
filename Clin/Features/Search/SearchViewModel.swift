//
//  SearchViewModel.swift
//  Clin
//
//  Created by asia on 13/08/2024.
//

import Foundation
import Factory

@Observable
final class SearchViewModel {
    enum ViewState {
        case idle
        case loading
        case loaded
    }
    
    enum FilterViewState {
        case idle
        case loading
        case loaded
    }
    
    var searchText: String = ""
    var viewState: ViewState = .idle
    var filterViewState: FilterViewState = .idle
   
    private(set) var filteredListings: [Listing] = []
    private(set) var searchSuggestions: [String] = []
    
    private let table: String = "car_listing"
    
    @ObservationIgnored
    @Injected(\.supabaseService) private var supabaseService
    @ObservationIgnored
    @Injected(\.listingService) private var listingService
    @ObservationIgnored
    @Injected(\.databaseService) private var databaseService
    
    // Filter properties
    var make: String = "Any"
    var model: String = "Any"
    var selectedYear: String = "Any"
    var maxPrice: Double = 10000
    var condition: String = "Any"
    var maxMileage: Double = 100000
    var range: String = "Any"
    var colour: String = "Any"
    var maxPublicChargingTime: String = "Any"
    var maxHomeChargingTime: String = "Any"
    var batteryCapacity: String = "Any"
    var powerBhp: String = "Any"
    var regenBraking: String = "Any"
    var warranty: String = "Any"
    var serviceHistory: String = "Any"
    var numberOfOwners: String = "Any"
    
    // Available properties to fetch
    var availableModels: [String] = []
    var availableColours: [String] = []
    var fetchedMakeModels: [EVMakeModels] = []
    
    var bodyType: [String] = []
    var yearOfManufacture: [String] = []
    var vehicleCondition: [String] = []
    var vehicleRange: [String] = []
    var homeCharge: [String] = []
    var publicCharge: [String] = []
    var batteryCap: [String] = []
    var vehicleRegenBraking: [String] = []
    var vehiclePowerBhp: [String] = []
    var vehicleWarranty: [String] = []
    var vehicleServiceHistory: [String] = []
    var vehicleNumberOfOwners: [String] = []

    init() {
        print("DEBUG: Did init search viewmodel")
    }
    
    @MainActor
    func resetState() {
        self.searchText = ""
        self.filteredListings.removeAll()
        viewState = .idle
    }
    
    @MainActor
    func resetFilters() {
        make = "Any"
        model = "Any"
        selectedYear = "Any"
        maxPrice = 10000
        selectedYear = "Any"
        condition = "Any"
        maxMileage = 100000
        range = "Any"
        colour = "Any"
        maxPublicChargingTime = "Any"
        maxHomeChargingTime = "Any"
        batteryCapacity = "Any"
        powerBhp = "Any"
        regenBraking = "Any"
        warranty = "Any"
        serviceHistory = "Any"
        numberOfOwners = "Any"
    }
    
    // Main search function based on search text
    @MainActor
    func searchItems() async {
        guard !searchText.isEmpty else { return }
        self.filteredListings.removeAll()
        self.viewState = .loading
        
        do {
            let searchResults = try await searchItemsFromSupabase(searchText: searchText)
            print("DEBUG: Search completed successfully for text: \(searchText)")
            self.filteredListings = searchResults
            self.viewState = .loaded
        } catch {
            print("DEBUG: Error fetching search results from Supabase: \(error)")
            self.filteredListings = []
        }
    }
    
    private func searchItemsFromSupabase(searchText: String) async throws -> [Listing] {
        do {
            let response: [Listing] = try await supabaseService.client
                .from(table)
                .select()
                .or("make.ilike.%\(searchText)%,model.ilike.%\(searchText)%,year.ilike.%\(searchText)%")
                .execute()
                .value
            print("DEBUG: Fetched \(response.count) listings from Supabase for text: \(searchText)")
            return response
        } catch {
            print("DEBUG: Failed to fetch listings from Supabase: \(error)")
            throw error
        }
    }
    
    @MainActor
    func fetchFilteredItems() async {
        self.filteredListings.removeAll()
        self.viewState = .loading
        
        do {
            var query = supabaseService.client
                .from(table)
                .select()
            
            // Applying filters for each property
            if !make.isEmpty {
                query = query.eq("make", value: make)
            }
            if !model.isEmpty {
                query = query.eq("model", value: model)
            }
            if !selectedYear.isEmpty {
                query = query.eq("year", value: selectedYear)
            }
            if maxPrice < 100000 {
                query = query.lte("price", value: maxPrice)
            }
            if maxMileage < 100000 {
                query = query.lte("mileage", value: maxMileage)
            }
            if !condition.isEmpty {
                query = query.eq("condition", value: condition)
            }
            if !range.isEmpty {
                query = query.eq("range", value: range)
            }
            if !colour.isEmpty {
                query = query.eq("colour", value: colour)
            }
            if !maxPublicChargingTime.isEmpty {
                query = query.lte("public_charging", value: maxPublicChargingTime)
            }
            if !maxHomeChargingTime.isEmpty {
                query = query.lte("home_charging", value: maxHomeChargingTime)
            }
            if !batteryCapacity.isEmpty {
                query = query.eq("battery_capacity", value: batteryCapacity)
            }
            if !powerBhp.isEmpty {
                query = query.eq("power_bhp", value: powerBhp)
            }
            if !regenBraking.isEmpty {
                query = query.eq("regen_braking", value: regenBraking)
            }
            if !warranty.isEmpty {
                query = query.eq("warranty", value: warranty)
            }
            if !serviceHistory.isEmpty {
                query = query.eq("service_history", value: serviceHistory)
            }
            if !numberOfOwners.isEmpty {
                query = query.eq("owners", value: numberOfOwners)
            }
            
            let response: [Listing] = try await query.execute().value
            
            self.filteredListings = response
            self.viewState = .loaded
        } catch {
            print("DEBUG: Error fetching filtered items from Supabase: \(error)")
            self.filteredListings = []
            self.viewState = .idle
        }
    }
       
    
//    // Fetch filtered items directly from the database
//    @MainActor
//    func fetchFilteredItems() async {
//        self.viewState = .loading
//        
//        do {
//            let query = supabaseService.client
//                .from(table1)
//                .select()
//                .eq("make", value: make)
//                .eq("model", value: model)
//                .eq("year", value: selectedYear)
//                .lte("price", value: maxPrice)
//                .lte("mileage", value: maxMileage)
//                .eq("condition", value: condition)
//                .eq("range", value: range)
//                .eq("colour", value: colour)
//                .lte("public_charging", value: maxPublicChargingTime)
//                .lte("home_charging", value: maxHomeChargingTime)
//                .eq("battery_capacity", value: batteryCapacity)
//                .eq("power_bhp", value: powerBhp)
//                .eq("regen_braking", value: regenBraking)
//                .eq("warranty", value: warranty)
//                .eq("service_history", value: serviceHistory)
//                .eq("owners", value: numberOfOwners)
//            
//            let response: [Listing] = try await query.execute().value
//            
//            self.filteredListings = response
//            self.viewState = .loaded
//        } catch {
//            print("DEBUG: Error fetching filtered items from Supabase: \(error)")
//            self.filteredListings = []
//            self.viewState = .idle
//        }
//    }
    

    @MainActor
    func fetchMakeModels() async {
        if fetchedMakeModels.isEmpty || availableModels.isEmpty {
            
            do {
                self.fetchedMakeModels = try await listingService.fetchMakeModels()
                self.make = fetchedMakeModels.first?.make ?? ""
                // Update available models based on the fetched car makes
                updateAvailableModels()
                
                print("DEBUG: Fetching make and models")
            } catch {
                print("DEBUG: Failed to fetch car makes and models from Supabase: \(error)")
            }
        }
    }
    
    @MainActor
    func fetchAvailableColours() async {
        do {
            let colours: [ColourResult] = try await supabaseService.client
                .from("car_listing")
                .select("colour")
                .execute()
                .value
            
            let uniqueColours = Set(colours.compactMap { $0.colour }).sorted()
            
            self.availableColours = uniqueColours
        } catch {
            print("DEBUG: Failed to fetch colours: \(error)")
        }
    }
        
    func updateAvailableModels() {
        guard let selectedCarMake = fetchedMakeModels.first(where: { $0.make == make }) else {
            availableModels = []
            self.model = ""
            return
        }
        
        // Update available models based on the selected make
        availableModels = selectedCarMake.models
        
        // Set the model to the first available one, or clear it if no models are available
        self.model = availableModels.first ?? ""
    }
    
    @MainActor
    func fetchEvSpecifications() async {
        do {
            let fetchedData: [EVSpecifications] = try await supabaseService.client
                .from("ev_specific")
                .select()
                .execute()
                .value
            
            // Clear existing data in the arrays to avoid duplicates
            bodyType.removeAll()
            yearOfManufacture.removeAll()
            vehicleCondition.removeAll()
            vehicleRange.removeAll()
            homeCharge.removeAll()
            publicCharge.removeAll()
            batteryCap.removeAll()
            vehicleRegenBraking.removeAll()
            vehicleWarranty.removeAll()
            vehicleServiceHistory.removeAll()
            vehicleNumberOfOwners.removeAll()
            vehiclePowerBhp.removeAll()
            
            // Iterate over the fetched data and append to arrays
            for evSpecific in fetchedData {
                bodyType.append(contentsOf: evSpecific.bodyType)
                yearOfManufacture.append(contentsOf: evSpecific.yearOfManufacture)
                vehicleCondition.append(contentsOf: evSpecific.condition)
                vehicleRange.append(contentsOf: evSpecific.range)
                homeCharge.append(contentsOf: evSpecific.homeChargingTime)
                publicCharge.append(contentsOf: evSpecific.publicChargingTime)
                batteryCap.append(contentsOf: evSpecific.batteryCapacity)
                vehicleRegenBraking.append(contentsOf: evSpecific.regenBraking)
                vehicleWarranty.append(contentsOf: evSpecific.warranty)
                vehicleServiceHistory.append(contentsOf: evSpecific.serviceHistory)
                vehicleNumberOfOwners.append(contentsOf: evSpecific.owners)
                vehiclePowerBhp.append(contentsOf: evSpecific.powerBhp)
            }
            
//            // Optionally, you can remove duplicates
//            bodyType = Array(Set(bodyType))
//            yearsOfmanufacture = Array(Set(yearsOfmanufacture))
//            vehicleCondition = Array(Set(vehicleCondition))
//            vehicleRange = Array(Set(vehicleRange))
//            homeCharge = Array(Set(homeCharge))
//            publicCharge = Array(Set(publicCharge))
//            batteryCap = Array(Set(batteryCap))
//            vehicleRegenBraking = Array(Set(vehicleRegenBraking))
//            vehicleWarranty = Array(Set(vehicleWarranty))
//            vehicleServiceHistory = Array(Set(vehicleServiceHistory))
//            vehicleNumberOfOwners = Array(Set(vehicleNumberOfOwners))
            
        } catch {
            print("DEBUG: Failed to fetch colours: \(error)")
        }
    }
}



