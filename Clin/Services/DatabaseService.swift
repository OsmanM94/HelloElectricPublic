import Foundation
import Factory

final class DatabaseService: DatabaseServiceProtocol {
    @Injected(\.supabaseService) private var supabaseService
    
    func loadPaginatedItems<T: Decodable>(from table: String, orderBy: String, ascending: Bool = true, from: Int, to: Int) async throws -> [T] {
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
    
    func loadPaginatedItemsWithListFilter<T: Decodable>(from table: String, filter: String ,values: [String], orderBy: String, orderBy2: String, ascending: Bool, from: Int, to: Int) async throws -> [T] {
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
    
    func searchPaginatedItemsWithOrFilter<T: Decodable> (from table: String, filter: String, from: Int, to: Int, orderBy: String, ascending: Bool) async throws -> [T] {
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
    
    func loadAllItems<T: Decodable>(from table: String, orderBy: String, ascending: Bool = true) async throws -> [T] {
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
    
    func loadItemByID<T: Decodable>(from table: String, id: Int) async throws -> T {
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
    
    func loadItemsByField<T: Decodable>(from table: String, orderBy: String, ascending: Bool = true, field: String, uuid: UUID) async throws -> [T] {
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
    
    func loadSingleItemByField<T: Decodable>(from table: String, field: String, uuid: UUID) async throws -> T {
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
    
    func insertItem<T: Encodable>(_ item: T, into table: String) async throws {
        do {
            try await supabaseService.client
                .from(table)
                .insert(item)
                .execute()
        } catch {
            throw error
        }
    }
    
    func updateItemByID<T: Encodable>(_ item: T, in table: String, id: Int) async throws {
        do {
            try await supabaseService.client
                .from(table)
                .update(item)
                .eq("id", value: id)
                .execute()
        } catch {
            throw error
        }
    }
    
    func updateItemByUserID<T: Encodable>(_ item: T, in table: String, userID: UUID) async throws {
        do {
            try await supabaseService.client
                .from(table)
                .update(item)
                .eq("user_id", value: userID)
                .execute()
        } catch {
            throw error
        }
    }
    
    func deleteItemByID(from table: String, id: Int) async throws {
        do {
            try await supabaseService.client
                .from(table)
                .delete()
                .eq("id", value: id)
                .execute()
        } catch {
            throw error
        }
    }
    
    func deleteItemByFields(from table: String, field: String, value: Int, field2: String, value2: UUID) async throws {
        do {
            try await supabaseService.client
                .from(table)
                .delete()
                .eq(field, value: value)
                .eq(field2, value: value2)
                .execute()
        } catch {
            throw error
        }
    }
    
    func deleteItemFromStorage(from table: String, path: [String]) async throws {
        do {
            _ = try await supabaseService.client.storage
                .from(table)
                .remove(paths: path)
        } catch {
            throw error
        }
    }
    
    func searchItemsWithComplexFilter<T: Decodable>(
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
