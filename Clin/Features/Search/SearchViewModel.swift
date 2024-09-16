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
    
    enum FilterViewState: Equatable {
        case loading
        case loaded
        case error(String)
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
    private let pageSize: Int = 20
    
    // Misc
    private var suggestionTapped: Bool = false
    let predefinedSuggestions: [String] = [
        "Tesla Model 3",
        "Nissan Leaf",
        "BMW i3",
        "Ford E-Transit"
    ]
    
    // MARK: - Dependencies
    @ObservationIgnored @Injected(\.searchFilters) var filters
    @ObservationIgnored @Injected(\.searchDataLoader) var dataLoader
    @ObservationIgnored @Injected(\.searchLogic) private var searchLogic
    
    init() {
        Logger.debug("SearchViewModel initialized")
    }
    
    // MARK: - Main actor functions
    
    @MainActor
    func loadBulkData() async {
        do {
            try await dataLoader.loadBulkData()
            updateAvailableModels()
            self.filterViewState = .loaded
        } catch {
            self.filterViewState = .error(AppError.ErrorType.generalError.message)
        }
    }

    @MainActor
    func loadMoreIfNeeded() async {
        if filters.isFilterApplied {
            await searchFilteredItems(isLoadingMore: true)
        } else {
            await searchItems(isLoadingMore: true)
        }
    }
    
    // Search no filters
    @MainActor
    func searchItems(isLoadingMore: Bool = false) async {
        guard !searchText.isEmpty else { return }

        do {
            try await performSearch(isLoadingMore: isLoadingMore) { [weak self] in
                guard let self = self else { return [] }
                
                return try await self.searchLogic
                    .searchItems(
                        searchText: self.currentSearchText,
                        from: self.currentPage * self.pageSize,
                        to: (self.currentPage + 1) * self.pageSize - 1)
            }
        } catch {
            self.viewState = .error(AppError.ErrorType.generalError.message)
        }
    }
    
    // Search with filters
    @MainActor
    func searchFilteredItems(isLoadingMore: Bool = false) async {
        do {
            try await performSearch(isLoadingMore: isLoadingMore) { [weak self] in
                guard let self = self else { return [] }
                return try await self.searchLogic.searchFilteredItems(
                    filters: self.filters,
                    from: self.currentPage * self.pageSize,
                    to: (self.currentPage + 1) * self.pageSize - 1
                )
            }
        } catch {
            self.viewState = .error(AppError.ErrorType.generalError.message)
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
        filters.reset()
    }
    
    // MARK: - Methods
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
    
    func updateAvailableModels() {
        let newModel = dataLoader.updateAvailableModels(make: self.filters.make, currentModel: self.filters.model)
        self.filters.updateModel(newModel)
    }
    
    // MARK: - Private methods
    private func performSearch(isLoadingMore: Bool, searchFunction: @escaping () async throws -> [Listing]) async throws{
        if !isLoadingMore {
            self.searchedItems.removeAll()
            self.currentPage = 0
            self.hasMoreListings = true
            self.currentSearchText = searchText
            viewState = .loading
        }
        guard hasMoreListings else { return }
        
        self.isSearching = true

        do {
            let response = try await searchFunction()

            if response.count < pageSize {
                self.hasMoreListings = false
            }
            
            searchedItems.append(contentsOf: response)
            self.currentPage += 1

            self.viewState = searchedItems.isEmpty ? .noResults : .loaded
        } catch {
            viewState = .error(AppError.ErrorType.generalError.message)
        }
        self.isSearching = false
    }
}

@Observable
final class SearchDataLoader {
    // MARK: - Data Arrays
    var loadedModels: [EVModels] = []
    var makeOptions: [String] { ["Any"] + loadedModels.map { $0.make } }
    var modelOptions: [String] = ["Any"]
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
    
    // MARK: - Dependencies
    @ObservationIgnored @Injected(\.searchService) private var searchService
    
    // MARK: - Methods
    func loadBulkData() async throws {
        do {
            try await loadModels()
            try await loadFeatures()
            try await loadLocations()
        } catch {
            Logger.error("Error loading bulk data: \(error)")
        }
    }
    
    func updateAvailableModels(make: String, currentModel: String) -> String {
        if make == "Any" {
            modelOptions = ["Any"] + loadedModels.flatMap { $0.models }
        } else if let selectedCarMake = loadedModels.first(where: { $0.make == make }) {
            modelOptions = ["Any"] + selectedCarMake.models
        } else {
            modelOptions = ["Any"]
        }
        
        return modelOptions.contains(currentModel) ? currentModel : "Any"
    }
    
    // MARK: - Private Methods
    private func loadLocations() async throws {
        let loadedData = try await searchService.loadCities()
        availableLocations = ["Any"] + loadedData.compactMap { $0.city }
    }
    
    private func loadFeatures() async throws {
        let loadedData = try await searchService.loadEVfeatures()
        populateFeatures(with: loadedData)
    }
    
    private func loadModels() async throws {
        if loadedModels.isEmpty {
            loadedModels = try await searchService.loadModels()
        }
    }
    
    private func populateFeatures(with loadedData: [EVFeatures]) {
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
    }
}

@Observable
final class SearchFilters {
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
    
    private(set) var isFilterApplied: Bool = false
    
    func updateModel(_ newModel: String) {
        self.model = newModel
        updateFilterState()
    }
    
    func reset() {
        make = "Any"
        model = "Any"
        body = "Any"
        location = "Any"
        selectedYear = "Any"
        maxPrice = 20_000
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
    
    private func updateFilterState() {
        isFilterApplied = isAnyFilterActive()
    }
    
    private func isAnyFilterActive() -> Bool {
        return make != "Any" ||
        model != "Any" ||
        body != "Any" ||
        location != "Any" ||
        selectedYear != "Any" ||
        maxPrice < 20_000 ||
        condition != "Any" ||
        maxMileage < 100_000 ||
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
}

final class SearchLogic {
    // MARK: - Dependencies
    @Injected(\.searchService) private var searchService
    
    // MARK: - Search methods
    func searchItems(searchText: String, from: Int, to: Int) async throws  -> [Listing] {
        let searchComponents = searchText.split(separator: " ").map { String($0) }
        
        let orConditions = searchComponents.map { component in
            """
            make.ilike.%\(component)%,model.ilike.%\(component)%
            """
        }.joined(separator: ",")
        
        return try await searchService.searchWithPaginationAndFilter(or: orConditions, from: from, to: to)
    }
        
    func searchFilteredItems(filters: SearchFilters, from: Int, to: Int) async throws -> [Listing] {
        var filterDict: [String: Any] = [:]
        
        if filters.make != "Any" { filterDict["make"] = filters.make }
        if filters.model != "Any" { filterDict["model"] = filters.model }
        if filters.body != "Any" { filterDict["body_type"] = filters.body }
        if filters.selectedYear != "Any" { filterDict["year"] = filters.selectedYear }
        if filters.maxPrice < 100000 { filterDict["price"] = filters.maxPrice }
        if filters.maxMileage < 500000 { filterDict["mileage"] = filters.maxMileage }
        if filters.condition != "Any" { filterDict["condition"] = filters.condition }
        if filters.range != "Any" { filterDict["range"] = filters.range }
        if filters.colour != "Any" { filterDict["colour"] = filters.colour }
        if filters.maxPublicChargingTime != "Any" { filterDict["public_charging"] = filters.maxPublicChargingTime }
        if filters.maxHomeChargingTime != "Any" { filterDict["home_charging"] = filters.maxHomeChargingTime }
        if filters.batteryCapacity != "Any" { filterDict["battery_capacity"] = filters.batteryCapacity }
        if filters.powerBhp != "Any" { filterDict["power_bhp"] = filters.powerBhp }
        if filters.regenBraking != "Any" { filterDict["regen_braking"] = filters.regenBraking }
        if filters.warranty != "Any" { filterDict["warranty"] = filters.warranty }
        if filters.serviceHistory != "Any" { filterDict["service_history"] = filters.serviceHistory }
        if filters.numberOfOwners != "Any" { filterDict["owners"] = filters.numberOfOwners }
        
        return try await searchService.searchFilteredItems(filters: filterDict, from: from, to: to)
    }
}


