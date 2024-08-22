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
    
    func loadWithPagination<T: Decodable>(from table: String, orderBy: String, ascending: Bool = true, from: Int, to: Int) async throws -> [T] {
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
    
    func loadAll<T: Decodable>(from table: String) async throws -> [T] {
        do {
            let result: [T] = try await supabaseService.client
                .from(table)
                .select()
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
    
    func loadMultipleWithField<T: Decodable>(from table: String, field: String, uuid: UUID) async throws -> [T] {
        do {
            let result: [T] = try await supabaseService.client
                .from(table)
                .select()
                .eq(field, value: uuid)
                .execute()
                .value
            return result
        } catch {
            throw error
        }
    }
    
    func loadSingleWithField<T: Decodable>(from table: String, field: String, uuid: UUID) async throws -> T {
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
}
