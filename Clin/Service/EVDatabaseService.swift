//
//  EVDatabaseService.swift
//  Clin
//
//  Created by asia on 13/09/2024.
//

import Foundation
import Factory

final class EVDatabaseService: EVDatabaseServiceProtocol {
    @Injected(\.databaseService) private var databaseService
    
    func loadPaginatedEVs(from: Int,to: Int) async throws -> [EVDatabase] {
        try await databaseService
            .loadPaginatedData(
                from: "ev_database",
                orderBy: "car_name",
                ascending: true,
                from: from,
                to: to
            )
    }
}