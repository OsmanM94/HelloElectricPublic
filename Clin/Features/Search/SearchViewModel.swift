//
//  SearchViewModel.swift
//  Clin
//
//  Created by asia on 13/08/2024.
//

import SwiftUI
import Factory

@Observable
final class SearchViewModel {
    // MARK: - Enums
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded
        case noResults
        case error(String)
    }
    
    enum FilterViewState {
        case loading
        case loaded
    }
    
    // MARK: - Error messages
    enum SearchViewStateErrorMessages: String, Error {
        case generalError = "An error occurred. Please try again."
        var message: String {
            return self.rawValue
        }
    }
    
    // MARK: - Observable properties
    // View state
    var viewState: ViewState = .idle
    var filterViewState: FilterViewState = .loading
    
    // Search properties
    var searchText: String = ""
    private(set) var searchedItems: [Listing] = []
    private(set) var isSearching: Bool = false
    private var currentSearchText: String = ""
    
    // Pagination
    private(set) var hasMoreListings: Bool = true
    private(set) var currentPage: Int = 0
    private let pageSize: Int = 10
    
    // Misc
    private let defaultMaxPrice: Double = 20_000
    private let defaultMaxMileage: Double = 100_000
    private(set) var isFilterApplied: Bool = false
    private let table: String = "car_listing"
    private var suggestionTapped: Bool = false
    let predefinedSuggestions: [String] = [
        "Tesla Model 3",
        "Nissan Leaf",
        "BMW i3",
        "Ford E-Transit"
    ]
    
    // MARK: - Dependencies
    @ObservationIgnored @Injected(\.supabaseService) private var supabaseService
    @ObservationIgnored @Injected(\.searchService) private var searchService
    
    // MARK: - Filter properties
    var make: String = "Any" { didSet { updateFilterState() } }
    var model: String = "Any" { didSet { updateFilterState() } }
    var location: String = "Any" { didSet { updateFilterState() } }
    var body: String = "Any" { didSet { updateFilterState() } }
    var selectedYear: String = "Any" { didSet { updateFilterState() } }
    var maxPrice: Double = 20_000 { didSet { updateFilterState() } }
    var condition: String = "Any" { didSet { updateFilterState() } }
    var maxMileage: Double = 100_000 { didSet { updateFilterState() } }
    var range: String = "Any" { didSet { updateFilterState() } }
    var colour: String = "Any" { didSet { updateFilterState() } }
    var maxPublicChargingTime: String = "Any" { didSet { updateFilterState() } }
    var maxHomeChargingTime: String = "Any" { didSet { updateFilterState() } }
    var batteryCapacity: String = "Any" { didSet { updateFilterState() } }
    var powerBhp: String = "Any" { didSet { updateFilterState() } }
    var regenBraking: String = "Any" { didSet { updateFilterState() } }
    var warranty: String = "Any" { didSet { updateFilterState() } }
    var serviceHistory: String = "Any" { didSet { updateFilterState() } }
    var numberOfOwners: String = "Any" { didSet { updateFilterState() } }
    
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
    
    @MainActor
    func loadMoreIfNeeded() async {
        if isFilterApplied {
            await searchFilteredItems(isLoadingMore: true)
        } else {
            await searchItems(isLoadingMore: true)
        }
    }
    
    // Search no filters
    @MainActor
    func searchItems(isLoadingMore: Bool = false) async {
        guard !searchText.isEmpty else { return }
        
        await performSearch(isLoadingMore: isLoadingMore) { [weak self] in
            guard let self = self else { return [] }
            
            return try await self.searchItemsFromSupabase(
                searchText: self.currentSearchText,
                from: self.currentPage * self.pageSize,
                to: (self.currentPage + 1) * self.pageSize - 1)
        }
    }
    
    // Search with filters
    @MainActor
    func searchFilteredItems(isLoadingMore: Bool = false) async {
        await performSearch(isLoadingMore: isLoadingMore) { [weak self] in
            guard let self = self else { return [] }
            var query = self.supabaseService.client
                .from(self.table)
                .select()
            
            // Applying filters only if the value is not "Any" or empty
            if !make.isEmpty && make != "Any" {
                query = query.eq("make", value: make)
            }
            if !model.isEmpty && model != "Any" {
                query = query.eq("model", value: model)
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

            return try await query
                .order("created_at", ascending: false)
                .range(from: self.currentPage * self.pageSize, to: (self.currentPage + 1) * self.pageSize - 1)
                .execute()
                .value
        }
    }
    
    @MainActor
    func clearSearch() {
        self.searchText = ""
        self.currentSearchText = ""
        self.searchedItems.removeAll()
        self.currentPage = 0
        self.hasMoreListings = true
        self.viewState = .idle
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
    
    private func searchItemsFromSupabase(searchText: String, from: Int, to: Int) async throws -> [Listing] {
        // Split the search text into individual words
        let searchComponents = searchText.split(separator: " ").map { String($0) }
        
        // Build a dynamic `or` condition that matches any of the components
        let orConditions = searchComponents.map { component in
               """
               make.ilike.%\(component)%,model.ilike.%\(component)%,year.ilike.%\(component)%,location.ilike.%\(component)%
               """
        }.joined(separator: ",")
        do {
            let response: [Listing] = try await supabaseService.client
                .from(table)
                .select()
                .or(orConditions)
                .range(from: from, to: to)
                .order("created_at", ascending: false)
                .execute()
                .value
            print("DEBUG: Loaded \(response.count) listings from Supabase for text: \(searchText)")
            return response
        } catch {
            print("DEBUG: Failed to load listings from Supabase: \(error)")
            viewState = .error(SearchViewStateErrorMessages.generalError.message)
            throw error
        }
    }
    
    private func performSearch(isLoadingMore: Bool, searchFunction: @escaping () async throws -> [Listing]) async {
        if !isLoadingMore {
            self.searchedItems.removeAll()
            self.currentPage = 0
            self.hasMoreListings = true
            self.currentSearchText = searchText
        }
        
        guard hasMoreListings else { return }
        viewState = .loading
        self.isSearching = true

            do {
                let response = try await searchFunction()

                if response.count < pageSize {
                    self.hasMoreListings = false
                }

                withAnimation {
                    searchedItems.append(contentsOf: response)
                }
                self.currentPage += 1

                self.viewState = searchedItems.isEmpty ? .noResults : .loaded
            } catch {
               print("Error searching \(error)")
                viewState = .error(SearchViewStateErrorMessages.generalError.message)
            }
            self.isSearching = false
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
    
    func handleSuggestionTap(_ suggestion: String) {
        guard !suggestionTapped else { return }
        suggestionTapped = true
        
        searchText = suggestion
        Task {
            await searchItems()
            DispatchQueue.main.async {
                self.suggestionTapped = false
            }
        }
    }
}





