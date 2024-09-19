//
//  EVDataViewModel.swift
//  Clin
//
//  Created by asia on 13/09/2024.
//

import Foundation
import Factory
import PostgREST

enum DatabaseFilter: String, CaseIterable {
    case all = "All"
    case recent = "Most Recent"
    case cheapest = "Cheapest"
    case power = "Power(HP)"
    case fastest = "Fastest"
    case towing = "Towing"
    case rapidCharging = "Rapid Charging"
    case mostEfficient = "Most Efficient"
    case longestRange = "Longest Range"
    
    var databaseValues: [[String: String]] {
        switch self {
        case .all:
            return [["column": "car_name", "order": "asc"]]
        case .recent:
            return [["column": "first_delivery_expected", "order": "desc"],
                    ["column": "car_name", "order": "asc"]]
        case .cheapest:
            return [["column": "car_price", "order": "asc"],
                    ["column": "car_name", "order": "asc"]]
        case .power:
            return [["column": "total_power", "order": "desc"],
                    ["column": "car_name", "order": "asc"]]
        case .fastest:
            return [["column": "performance_acceleration_0_62_mph", "order": "asc"],
                    ["column": "car_name", "order": "asc"]]
        case .towing:
            return [["column": "dimensions_tow", "order": "desc"],
                    ["column": "car_name", "order": "asc"]]
        case .rapidCharging:
            return [["column": "charging_rapid_charge_time", "order": "asc"],
                    ["column": "car_name", "order": "asc"]]
        case .mostEfficient:
            return [["column": "efficiency_real_range_consumption", "order": "asc"],
                    ["column": "car_name", "order": "asc"]]
        case .longestRange:
            return [["column": "electric_range", "order": "desc"],
                    ["column": "car_name", "order": "asc"]]
        }
    }
}


@Observable
final class EVDataViewModel {
    // MARK: - Enum
    enum ViewState: Equatable {
        case loading
        case loaded
        case empty
        case error(String)
    }
    
    // MARK: - Observable properties
    private(set) var evDatabase: [EVDatabase] = []
    private(set) var viewState: ViewState = .loading
    
    // MARK: - Search properties
    var searchText: String = ""
    private(set) var isSearching: Bool = false
    private var currentSearchText: String = ""
    
    // MARK: - Filter
    var databaseFilter: DatabaseFilter = .all
    
    // MARK: - Pagination control
    private(set) var hasMoreListings: Bool = true
    private(set) var currentPage: Int = 0
    private let pageSize: Int = 20
    private(set) var isListEmpty: Bool = false
    
    // MARK: - Dependencies
    @ObservationIgnored @Injected(\.evDatabase) private var evDatabaseService
    @ObservationIgnored @Injected(\.supabaseService) private var supabaseService
    
    private let table: String = "ev_database"
    
    // MARK: - Main actor functions
    
    @MainActor
    func searchItems() async {
        guard !searchText.isEmpty else { return }
        
        evDatabase.removeAll()
        currentPage = 0
        hasMoreListings = true
        currentSearchText = searchText
        viewState = .loading
        
        guard hasMoreListings else { return }
        
        isSearching = true
        
        do {
            let newEVs = try await searchEVs(
                searchText: currentSearchText,
                from: currentPage * pageSize,
                to: (currentPage + 1) * pageSize - 1
            )
            
            if newEVs.count < pageSize {
                hasMoreListings = false
            }
            
            evDatabase.append(contentsOf: newEVs)
            currentPage += 1
            
            viewState = evDatabase.isEmpty ? .empty : .loaded
        } catch {
            print("Error searching EV database: \(error)")
            viewState = .error(AppError.ErrorType.generalError.message)
        }
        
        isSearching = false
    }
    
    @MainActor
    func clearSearch() {
        searchText = ""
        currentSearchText = ""
        evDatabase.removeAll()
        currentPage = 0
        hasMoreListings = true
        viewState = .loaded
    }
    
    @MainActor
    func loadEVDatabase() async {
        resetPagination()
        await loadEVs()
    }
    
    @MainActor
    func loadMoreFromDatabase() async {
        guard hasMoreListings, viewState != .loading else { return }
        await loadEVs()
    }
    
    @MainActor
    func resetState() {
        searchText = ""
        evDatabase.removeAll()
        resetPagination()
        viewState = .loading
    }
    
    @MainActor
    func resetStateToLoaded() {
        resetPagination()
        Task {
            await loadEVs()
        }
    }
    
    // MARK: - Private methods
    private func resetPagination() {
        self.currentPage = 0
        self.hasMoreListings = true
        self.evDatabase = []
        self.viewState = .loading
    }
    
    private func searchEVs(searchText: String, from: Int, to: Int) async throws -> [EVDatabase] {
        let searchComponents = searchText.split(separator: " ").map { String($0) }
        
        let orConditions = searchComponents.map { component in
            "car_name.ilike.%\(component)%"
        }.joined(separator: ",")
        
        return try await supabaseService.client
            .from(table)
            .select()
            .or(orConditions)
            .range(from: from, to: to)
            .order("car_name", ascending: false)
            .execute()
            .value
    }
    
    private func loadEVs() async {
        do {
            let newEVs = try await searchDatabaseWithFilter()
            
            if newEVs.isEmpty {
                hasMoreListings = false
            } else {
                evDatabase.append(contentsOf: newEVs)
                currentPage += 1
            }
            
            viewState = evDatabase.isEmpty ? .empty : .loaded
        } catch {
            print("Error loading EV database \(error)")
            viewState = .error(AppError.ErrorType.generalError.message)
        }
    }
        
    private func searchDatabaseWithFilter() async throws -> [EVDatabase] {
        do {
            let filterValues = self.databaseFilter.databaseValues
            
            var query = supabaseService.client
                .from(table)
                .select()
            
            // Apply order for multiple columns
            for filter in filterValues {
                let column = filter["column"] ?? "car_name"
                let order = filter["order"] ?? "asc"
                query = query.order(column, ascending: order == "asc") as! PostgrestFilterBuilder
            }
            
            // Apply pagination
            let result: [EVDatabase] = try await query
                .range(from: currentPage * pageSize, to: (currentPage + 1) * pageSize - 1)
                .execute()
                .value
            
            return result
        } catch {
            throw error
        }
    }
}
