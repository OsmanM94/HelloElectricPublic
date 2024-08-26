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
}
