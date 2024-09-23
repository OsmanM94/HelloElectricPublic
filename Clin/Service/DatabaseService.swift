//
//  DatabaseService.swift
//  Clin
//
//  Created by asia on 17/08/2024.
//

import Foundation
import Factory

final class DatabaseService: DatabaseServiceProtocol {
    @Injected(\.supabaseService) private var supabaseService
    
    func loadPaginatedData<T: Decodable>(from table: String, orderBy: String, ascending: Bool = true, from: Int, to: Int) async throws -> [T] {
            do {
                let result: [T] = try await supabaseService.client
                    .from(table)
                    .select()
                    .order(orderBy, ascending: ascending)
                    .range(from: from, to: to)
                    .execute()
                    .value
                return result
            } catch {
                throw error
            }
        }
    
    func loadPaginatedDataWithListFilter<T: Decodable>(from table: String, filter: String ,values: [String], orderBy: String, orderBy2: String, ascending: Bool, from: Int, to: Int) async throws -> [T] {
        do {
            let result: [T] = try await supabaseService.client
                .from(table)
                .select()
                .in(filter, values: values)
                .order(orderBy, ascending: ascending)
                .order(orderBy2, ascending: ascending)
                .range(from: from, to: to)
                .execute()
                .value
            return result
        } catch {
            throw error
        }
    }
    
    func searchPaginatedDataWithOrFilter<T: Decodable> (from table: String, filter: String, from: Int, to: Int, orderBy: String, ascending: Bool) async throws -> [T] {
        do {
            let result: [T] = try await supabaseService.client
                .from(table)
                .select()
                .or(filter)
                .range(from: from, to: to)
                .order(orderBy, ascending: ascending)
                .execute()
                .value
            return result
        } catch {
            throw error
        }
    }
    
    func loadAll<T: Decodable>(from table: String, orderBy: String, ascending: Bool = true) async throws -> [T] {
        do {
            let result: [T] = try await supabaseService.client
                .from(table)
                .select()
                .order(orderBy, ascending: ascending)
                .execute()
                .value
            return result
        } catch {
            throw error
        }
    }
    
    func loadByID<T: Decodable>(from table: String, id: Int) async throws -> T {
        do {
            let result: T = try await supabaseService.client
                .from(table)
                .select()
                .eq("id", value: id)
                .single()
                .execute()
                .value
            return result
        } catch {
            throw error
        }
    }
    
    func loadMultipleItems<T: Decodable>(from table: String, orderBy: String, ascending: Bool = true, field: String, uuid: UUID) async throws -> [T] {
        do {
            let result: [T] = try await supabaseService.client
                .from(table)
                .select()
                .eq(field, value: uuid)
                .order(orderBy, ascending: ascending)
                .execute()
                .value
            return result
        } catch {
            throw error
        }
    }
    
    func loadSingleItem<T: Decodable>(from table: String, field: String, uuid: UUID) async throws -> T {
        do {
            let result: T = try await supabaseService.client
                .from(table)
                .select()
                .eq(field, value: uuid)
                .single()
                .execute()
                .value
            return result
        } catch {
            throw error
        }
    }
    
    func insert<T: Encodable>(_ item: T, into table: String) async throws {
        do {
            try await supabaseService.client
                .from(table)
                .insert(item)
                .execute()
            print("DEBUG: Item inserted successfully into \(table).")
        } catch {
            throw error
        }
    }
    
    func update<T: Encodable>(_ item: T, in table: String, id: Int) async throws {
        do {
            try await supabaseService.client
                .from(table)
                .update(item)
                .eq("id", value: id)
                .execute()
            print("DEBUG: Item updated successfully in \(table).")
        } catch {
            throw error
        }
    }
    
    func updateByUUID<T: Encodable>(_ item: T, in table: String, userID: UUID) async throws {
        do {
            try await supabaseService.client
                .from(table)
                .update(item)
                .eq("user_id", value: userID)
                .execute()
            print("DEBUG: Item updated successfully in \(table).")
        } catch {
            throw error
        }
    }
    
    func delete(from table: String, id: Int) async throws {
        do {
            try await supabaseService.client
                .from(table)
                .delete()
                .eq("id", value: id)
                .execute()
            print("DEBUG: Item deleted successfully from \(table).")
        } catch {
            throw error
        }
    }
    
    func deleteByField(from table: String, field: String, value: Int, field2: String, value2: UUID) async throws {
        do {
            try await supabaseService.client
                .from(table)
                .delete()
                .eq(field, value: value)
                .eq(field2, value: value2)
                .execute()
            print("DEBUG: Item deleted successfully from \(table).")
        } catch {
            throw error
        }
    }
    
    func searchWithComplexFilter<T: Decodable>(
           from table: String,
           filters: [String: Any],
           from: Int,
           to: Int,
           orderBy: String,
           ascending: Bool = true
       ) async throws -> [T] {
           var query = supabaseService.client.from(table).select()
           
           for (key, value) in filters {
               if let stringValue = value as? String, stringValue != "Any" {
                   query = query.eq(key, value: stringValue)
               } else if let intValue = value as? Int {
                   query = query.eq(key, value: intValue)
               } else if let doubleValue = value as? Double {
                   query = query.lte(key, value: doubleValue)
               }
           }
           
           let result: [T] = try await query
               .order(orderBy, ascending: ascending)
               .range(from: from, to: to)
               .execute()
               .value
           
           return result
       }
}
