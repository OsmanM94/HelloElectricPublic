//
//  EVDatabaseService.swift
//  Clin
//
//  Created by asia on 13/09/2024.
//

import Foundation
import Factory

final class EVDatabaseService: EVDatabaseServiceProtocol {
    func searchEVs(searchText: String, from: Int, to: Int) async throws -> [EVDatabase] {
        <#code#>
    }
    
    func loadEVs(filter: DatabaseFilter, from: Int, to: Int) async throws -> [EVDatabase] {
        <#code#>
    }
    
    @Injected(\.databaseService) private var databaseService
    
    func loadPaginatedEVs(from: Int,to: Int) async throws -> [EVDatabase] {
        try await databaseService
            .loadPaginatedItems(
                from: "ev_database",
                orderBy: "car_name",
                ascending: true,
                from: from,
                to: to
            )
    }
}
