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
    private(set) var database: [EVDatabase] = []
    private(set) var viewState: ViewState = .loading
    
    // MARK: - Pagination control
    private(set) var hasMoreListings: Bool = true
    private(set) var currentPage: Int = 0
    private let pageSize: Int = 20
    private(set) var isListEmpty: Bool = false
    
    // MARK: - Dependencies
    @ObservationIgnored @Injected(\.evDatabase) private var evDatabaseService
    
    // MARK: - Main actor functions
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
        resetPagination()
        viewState = .loading
    }
    
    // MARK: - Private methods
    private func resetPagination() {
        self.currentPage = 0
        self.hasMoreListings = true
        self.database = []
    }
    
    private func loadEVs() async {
        do {
            let newEVs = try await evDatabaseService.loadPaginatedEVs(
                from: currentPage * pageSize,
                to: (currentPage * pageSize) + pageSize - 1
            )
            
            if newEVs.isEmpty {
                hasMoreListings = false
                viewState = database.isEmpty ? .empty : .loaded
            } else {
                database.append(contentsOf: newEVs)
                viewState = .loaded
            }
        } catch {
            print("Error loading EV database \(error)")
            viewState = .error(AppError.ErrorType.generalError.message)
        }
    }
}
