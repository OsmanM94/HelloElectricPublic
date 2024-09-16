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
            .loadAll(from: "ev_make", orderBy: "make", ascending: true)
    }
    
    func loadCities() async throws -> [Cities] {
        try await databaseService
            .loadAll(from: "uk_cities", orderBy: "id", ascending: true)
    }
    
    func loadEVfeatures() async throws -> [EVFeatures] {
        try await databaseService
            .loadAll(from: "ev_features", orderBy: "id", ascending: true)
    }
    
    func searchWithPaginationAndFilter(or: String, from: Int, to: Int) async throws -> [Listing] {
        try await databaseService
            .searchPaginatedDataWithOrFilter(
                from: "car_listing",
                filter: or,
                from: from,
                to: to,
                orderBy: "created_at",
                ascending: false
            )
    }
    
    func searchFilteredItems(filters: [String: Any], from: Int, to: Int) async throws -> [Listing] {
        try await databaseService
            .searchWithComplexFilter(
                from: "car_listing",
                filters: filters,
                from: from,
                to: to,
                orderBy: "created_at",
                ascending: false
            )
    }
}
