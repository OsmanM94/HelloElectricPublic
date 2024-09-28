//
//  EVDatabaseService.swift
//  Clin
//
//  Created by asia on 13/09/2024.
//

import Foundation
import Factory
import PostgREST


final class EVDatabaseService: EVDatabaseServiceProtocol {
    @Injected(\.databaseService) private var databaseService
    @Injected(\.supabaseService) private var supabaseService
    
    private let table: String = "ev_database"
    
    func searchEVs(searchText: String, from: Int, to: Int) async throws -> [EVDatabase] {
        let searchComponents = searchText.split(separator: " ").map { String($0) }
        let orConditions = searchComponents.map { component in
            "car_name.ilike.%\(component)%"
        }.joined(separator: ",")
        
        return try await databaseService.searchPaginatedItemsWithOrFilter(
            from: table,
            filter: orConditions,
            from: from,
            to: to,
            orderBy: "car_name",
            ascending: false
        )
    }
    
    func loadEVs(filter: DatabaseFilter, from: Int, to: Int) async throws -> [EVDatabase] {
        do {
            let filterValues = filter.databaseValues
            
            var query = supabaseService.client
                .from(table)
                .select()
            
            // Apply order for multiple columns
            // Note: This method of applying multiple order clauses works with the current version of the Supabase PostgREST client.
            // If you upgrade the client or encounter issues, you might need to revisit this implementation.
            for filter in filterValues {
                let column = filter["column"] ?? "car_name"
                let order = filter["order"] ?? "asc"
                query = query.order(column, ascending: order == "asc") as! PostgrestFilterBuilder
            }
            
            // Apply pagination
            let result: [EVDatabase] = try await query
                .range(from: from, to: to)
                .execute()
                .value
            
            return result
        } catch {
            throw error
        }
    }
    
}
