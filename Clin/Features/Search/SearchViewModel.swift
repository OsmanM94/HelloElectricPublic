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
    // MARK: - Enums
    enum ViewState {
        case idle
        case loading
        case loaded
        case empty
    }
    
    enum FilterViewState {
        case loading
        case loaded
    }
    
    // MARK: - Observable properties
    // View state
    var viewState: ViewState = .idle
    var filterViewState: FilterViewState = .loading
    
    // Search properties
    var searchText: String = ""
    private(set) var searchedItems: [Listing] = []
   
    // Misc
    private let defaultMaxPrice: Double = 20_000
    private let defaultMaxMileage: Double = 100_000
    private(set) var isFilterApplied: Bool = false
    private let table: String = "car_listing"
    
    // MARK: - Dependencies
    @ObservationIgnored @Injected(\.supabaseService) private var supabaseService
    @ObservationIgnored @Injected(\.searchService) private var searchService
    
    // MARK: - Filter properties
    var make: String = "Any" {
        didSet { updateFilterState() }
    }
    var model: String = "Any" {
        didSet { updateFilterState() }
    }
    var location: String = "Any" {
        didSet { updateFilterState() }
    }
    var body: String = "Any" {
        didSet { updateFilterState() }
    }
    var selectedYear: String = "Any" {
        didSet { updateFilterState() }
    }
    var maxPrice: Double = 20_000 {
        didSet { updateFilterState() }
    }
    var condition: String = "Any" {
        didSet { updateFilterState() }
    }
    var maxMileage: Double = 100_000 {
        didSet { updateFilterState() }
    }
    var range: String = "Any" {
        didSet { updateFilterState() }
    }
    var colour: String = "Any" {
        didSet { updateFilterState() }
    }
    var maxPublicChargingTime: String = "Any" {
        didSet { updateFilterState() }
    }
    var maxHomeChargingTime: String = "Any" {
        didSet { updateFilterState() }
    }
    var batteryCapacity: String = "Any" {
        didSet { updateFilterState() }
    }
    var powerBhp: String = "Any" {
        didSet { updateFilterState() }
    }
    var regenBraking: String = "Any" {
        didSet { updateFilterState() }
    }
    var warranty: String = "Any" {
        didSet { updateFilterState() }
    }
    var serviceHistory: String = "Any" {
        didSet { updateFilterState() }
    }
    var numberOfOwners: String = "Any" {
        didSet { updateFilterState() }
    }
    
    // MARK: - Data Array
    var loadedModels: [EVModels] = []
    var makeOptions: [String] { ["Any"] + loadedModels.map { $0.make } }
    var modelOptions: [String] = []
    var availableLocations: [String] = []
    var bodyTypeOptions: [String] = []
    var yearOptions: [String] = []
    var conditionOptions: [String] = []
    var rangeOptions: [String] = []
    var colourOptions: [String] = []
    var publicChargingTimeOptions: [String] = []
    var homeChargingTimeOptions: [String] = []
    var batteryCapacityOptions: [String] = []
    var powerBhpOptions: [String] = []
    var regenBrakingOptions: [String] = []
    var warrantyOptions: [String] = []
    var serviceHistoryOptions: [String] = []
    var numberOfOwnersOptions: [String] = []
    
    init() {
        print("DEBUG: Did init search viewmodel")
    }
    
    // MARK: - Main actor functions
    
    @MainActor
    func loadBulkData() async {
        self.filterViewState = .loading
        await loadModels()
        await loadEVFeatures()
        await loadLocations()
        self.filterViewState = .loaded
    }
    
    // Search no filters
    @MainActor
    func searchItems() async {
        guard !searchText.isEmpty else { return }
        self.searchedItems.removeAll()
        self.viewState = .loading
        
        do {
            let response = try await searchItemsFromSupabase(searchText: searchText)
            print("DEBUG: Search completed successfully for text: \(searchText)")
            self.searchedItems = response
            
            if self.searchedItems.isEmpty {
                self.viewState = .empty
            } else {
                self.viewState = .loaded
            }
        } catch {
            print("DEBUG: Error loading search results from Supabase: \(error)")
            self.searchedItems = []
            self.viewState = .idle
        }
    }
    
    // Search with filters
    @MainActor
    func searchFilteredItems() async {
        self.searchedItems.removeAll()
        self.viewState = .loading
        do {
            var query = supabaseService.client
                .from(table)
                .select()
            
            // Applying filters only if the value is not "Any" or empty
            if !make.isEmpty && make != "Any" {
                query = query.ilike("make", pattern: make)
                
                print("DEBUG: Applied filter for make: \(make)")
            }
            if !model.isEmpty && model != "Any" {
                query = query.ilike("model", pattern: model)
                
                print("DEBUG: Applied filter for model: \(model)")
            }
            if !selectedYear.isEmpty && selectedYear != "Any" {
                query = query.eq("year", value: selectedYear)
            }
            if maxPrice < 100000 {
                query = query.lte("price", value: maxPrice)
            }
            if maxMileage < 500000 {
                query = query.lte("mileage", value: maxMileage)
            }
            if !condition.isEmpty && condition != "Any" {
                query = query.eq("condition", value: condition)
            }
            if !range.isEmpty && range != "Any" {
                query = query.eq("range", value: range)
            }
            if !colour.isEmpty && colour != "Any" {
                query = query.eq("colour", value: colour)
            }
            if !maxPublicChargingTime.isEmpty && maxPublicChargingTime != "Any" {
                query = query.lte("public_charging", value: maxPublicChargingTime)
            }
            if !maxHomeChargingTime.isEmpty && maxHomeChargingTime != "Any" {
                query = query.lte("home_charging", value: maxHomeChargingTime)
            }
            if !batteryCapacity.isEmpty && batteryCapacity != "Any" {
                query = query.eq("battery_capacity", value: batteryCapacity)
            }
            if !powerBhp.isEmpty && powerBhp != "Any" {
                query = query.eq("power_bhp", value: powerBhp)
            }
            if !regenBraking.isEmpty && regenBraking != "Any" {
                query = query.eq("regen_braking", value: regenBraking)
            }
            if !warranty.isEmpty && warranty != "Any" {
                query = query.eq("warranty", value: warranty)
            }
            if !serviceHistory.isEmpty && serviceHistory != "Any" {
                query = query.eq("service_history", value: serviceHistory)
            }
            if !numberOfOwners.isEmpty && numberOfOwners != "Any" {
                query = query.eq("owners", value: numberOfOwners)
            }
            
            let response: [Listing] = try await query.execute().value
            
            self.searchedItems = response
            
            if self.searchedItems.isEmpty {
                self.viewState = .empty
            } else {
                self.viewState = .loaded
            }
        } catch {
            print("DEBUG: Error loading filtered items from Supabase: \(error)")
            self.searchedItems = []
            self.viewState = .idle
        }
    }
    
    @MainActor
    func resetState() {
        self.searchText = ""
        self.searchedItems.removeAll()
        viewState = .idle
    }
    
    @MainActor
    func resetFilters() {
        make = "Any"
        model = "Any"
        location = "Any"
        selectedYear = "Any"
        maxPrice = 20_000
        selectedYear = "Any"
        condition = "Any"
        maxMileage = 100_000
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
    
    // MARK: - Helpers and misc
    
    private func isAnyFilterActive() -> Bool {
        return make != "Any" ||
        model != "Any" ||
        location != "Any" ||
        selectedYear != "Any" ||
        maxPrice < defaultMaxPrice ||
        condition != "Any" ||
        maxMileage < defaultMaxMileage ||
        range != "Any" ||
        colour != "Any" ||
        maxPublicChargingTime != "Any" ||
        maxHomeChargingTime != "Any" ||
        batteryCapacity != "Any" ||
        powerBhp != "Any" ||
        regenBraking != "Any" ||
        warranty != "Any" ||
        serviceHistory != "Any" ||
        numberOfOwners != "Any"
    }
    
    private func updateFilterState() {
        isFilterApplied = isAnyFilterActive()
    }
    
    private func searchItemsFromSupabase(searchText: String) async throws -> [Listing] {
        do {
            let response: [Listing] = try await supabaseService.client
                .from(table)
                .select()
                .or("make.ilike.%\(searchText)%,model.ilike.%\(searchText)%,year.ilike.%\(searchText)%,location.ilike.%\(searchText)%")
                .execute()
                .value
            print("DEBUG: Loaded \(response.count) listings from Supabase for text: \(searchText)")
            return response
        } catch {
            print("DEBUG: Failed to load listings from Supabase: \(error)")
            throw error
        }
    }
    
    private func loadModels() async {
        if loadedModels.isEmpty {
            do {
                self.loadedModels = try await searchService.loadModels()
                
                // Update available models
                updateAvailableModels()
                
                print("DEBUG: Loading make and models")
            } catch {
                print("DEBUG: Failed to load car makes and models from Supabase: \(error)")
            }
        }
    }
    
    private func loadLocations() async {
        do {
            let loadedData = try await searchService.loadCities()
            
            // Clear existing data in the arrays to avoid duplicates
            availableLocations = ["Any"] + loadedData.compactMap { $0.city }
            
        } catch {
            print("DEBUG: Failed to load UK cities: \(error)")
        }
    }
    
    private func loadEVFeatures() async {
        do {
            let loadedData = try await searchService.loadEVfeatures()
            
            bodyTypeOptions = ["Any"] + loadedData.flatMap { $0.bodyType }
            yearOptions = ["Any"] + loadedData.flatMap { $0.yearOfManufacture }
            conditionOptions = ["Any"] + loadedData.flatMap { $0.condition }
            rangeOptions = ["Any"] + loadedData.flatMap { $0.range }
            homeChargingTimeOptions = ["Any"] + loadedData.flatMap { $0.homeChargingTime }
            publicChargingTimeOptions = ["Any"] + loadedData.flatMap { $0.publicChargingTime }
            batteryCapacityOptions = ["Any"] + loadedData.flatMap { $0.batteryCapacity }
            regenBrakingOptions = ["Any"] + loadedData.flatMap { $0.regenBraking }
            warrantyOptions = ["Any"] + loadedData.flatMap { $0.warranty }
            serviceHistoryOptions = ["Any"] + loadedData.flatMap { $0.serviceHistory }
            numberOfOwnersOptions = ["Any"] + loadedData.flatMap { $0.owners }
            powerBhpOptions = ["Any"] + loadedData.flatMap { $0.powerBhp }
            colourOptions = ["Any"] + loadedData.flatMap { $0.colours }
            
        } catch {
            print("DEBUG: Failed to load ev features: \(error)")
        }
    }
    
    func updateAvailableModels() {
        if make == "Any" {
            modelOptions = ["Any"] + loadedModels.flatMap { $0.models }
        } else if let selectedCarMake = loadedModels.first(where: { $0.make == make }) {
            modelOptions = ["Any"] + selectedCarMake.models
        } else {
            modelOptions = ["Any"]
        }
        
        // Check if the current model is still valid in the new list of available models
        if !modelOptions.contains(model) {
            self.model = "Any"
        }
    }
}





