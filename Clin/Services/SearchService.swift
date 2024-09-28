//
//  SearchService.swift
//  Clin
//
//  Created by asia on 22/08/2024.
//

import Foundation
import Factory

final class SearchService: SearchServiceProtocol {
    @Injected(\.databaseService) var databaseService: DatabaseServiceProtocol
    
    func loadModels() async throws -> [EVModels] {
        try await databaseService
            .loadAllItems(from: "ev_make", orderBy: "make", ascending: true)
    }
    
    func loadCities() async throws -> [Cities] {
        try await databaseService
            .loadAllItems(from: "uk_cities", orderBy: "id", ascending: true)
    }
    
    func loadEVfeatures() async throws -> [EVFeatures] {
        try await databaseService
            .loadAllItems(from: "ev_features", orderBy: "id", ascending: true)
    }
    
    func searchWithPaginationAndFilter(or: String, from: Int, to: Int) async throws -> [Listing] {
        try await databaseService
            .searchPaginatedItemsWithOrFilter(
                from: "car_listing",
                filter: or,
                from: from,
                to: to,
                orderBy: "refreshed_at",
                ascending: false
            )
    }
    
    func searchFilteredItems(filters: [String: Any], from: Int, to: Int) async throws -> [Listing] {
        try await databaseService
            .searchItemsWithComplexFilter(
                from: "car_listing",
                filters: filters,
                from: from,
                to: to,
                orderBy: "refreshed_at",
                ascending: false
            )
    }
}
