//
//  EVDataViewModel.swift
//  Clin
//
//  Created by asia on 13/09/2024.
//

import Foundation
import Factory

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
    func loadMoreEVDatabase() async {
        guard hasMoreListings, viewState != .loading else { return }
        currentPage += 1
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
        viewState = .loaded
    }
    
    // MARK: - Private methods
    private func resetPagination() {
        self.currentPage = 0
        self.hasMoreListings = true
        self.evDatabase = []
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
            .order("available_since", ascending: false)
            .execute()
            .value
    }
    
    private func loadEVs() async {
        do {
            let newEVs = try await evDatabaseService.loadPaginatedEVs(
                from: currentPage * pageSize,
                to: (currentPage * pageSize) + pageSize - 1
            )
            
            if newEVs.isEmpty {
                hasMoreListings = false
                viewState = evDatabase.isEmpty ? .empty : .loaded
            } else {
                evDatabase.append(contentsOf: newEVs)
                viewState = .loaded
            }
        } catch {
            print("Error loading EV database \(error)")
            viewState = .error(AppError.ErrorType.generalError.message)
        }
    }
}
