//
//  CarListingService.swift
//  Clin
//
//  Created by asia on 24/06/2024.
//

import Foundation
import PostgREST


//struct ListingService: ListingServiceProtocol {
//    
//    func fetchPaginatedListings(from: Int, to: Int) async throws -> [Listing] {
//        do {
//            let listings: [Listing] = try await Supabase.shared.client
//                .from("car_listing")
//                .select()
//                .order("created_at", ascending: false)
//                .range(from: from, to: to)
//                .execute()
//                .value
//            return listings
//        } catch {
//            throw error
//        }
//    }
//    
//    func fetchListings(id: Int) async throws -> Listing {
//        do {
//            let listing: Listing = try await Supabase.shared.client
//                .from("car_listing")
//                .select()
//                .eq("id", value: id)
//                .single()
//                .execute()
//                .value
//            return listing
//        } catch {
//            throw error
//        }
//    }
//    
//    func fetchMakeModels() async throws -> [CarMake] {
//        do {
//            let makeAndModels: [CarMake] = try await Supabase.shared.client
//                .from("car_make")
//                .select("*")
//                .execute()
//                .value
//            return makeAndModels
//        } catch {
//            throw error
//        }
//    }
//    
//    func fetchUserListings(userID: UUID) async throws -> [Listing] {
//        do {
//            let listings: [Listing] = try await Supabase.shared.client
//                .from("car_listing")
//                .select()
//                .eq("user_id", value: userID)
//                .order("created_at", ascending: false)
//                .execute()
//                .value
//            print("DEBUG: User listings retrieved succesfully.")
//            return listings
//        } catch {
//            throw error
//        }
//    }
//    
//    func createListing(_ listing: Listing) async throws {
//        do {
//            try await Supabase.shared.client
//                .from("car_listing")
//                .insert(listing)
//                .execute()
//            print("DEBUG: Listing created successfully.")
//        } catch {
//            throw error
//        }
//    }
//    
//    func updateListing(_ listing: Listing) async throws {
//        guard let id = listing.id else {
//            print("DEBUG: Listing ID is missing.")
//            return
//        }
//        do {
//            try await Supabase.shared.client
//                .from("car_listing")
//                .update(listing)
//                .eq("id", value: id)
//                .execute()
//            print("DEBUG: Listing updated succesfully.")
//        } catch {
//            throw error
//        }
//    }
//    
//    func deleteListing(at id: Int) async throws {
//        do {
//            try await Supabase.shared.client
//                .from("car_listing")
//                .delete()
//                .eq("id", value: id)
//                .execute()
//            print("DEBUG: Listing deleted successfully.")
//        } catch {
//            throw error
//        }
//    }
//}


protocol DatabaseServiceProtocol {
    func fetchPagination<T: Decodable>(from table: String, orderBy: String, ascending: Bool, from: Int, to: Int) async throws -> [T]
    func fetchAll<T: Decodable>(from table: String) async throws -> [T]
    func fetchByID<T: Decodable>(from table: String, id: Int) async throws -> T
    func fetchByField<T: Decodable>(from table: String, field: String, value: UUID) async throws -> [T]
    func insert<T: Encodable>(_ item: T, into table: String) async throws
    func update<T: Encodable>(_ item: T, in table: String, id: Int) async throws
    func delete(from table: String, id: Int) async throws
}

struct DatabaseService: DatabaseServiceProtocol {
    func fetchPagination<T: Decodable>(from table: String, orderBy: String, ascending: Bool = true, from: Int, to: Int) async throws -> [T] {
        do {
            let result: [T] = try await Supabase.shared.client
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
    
    func fetchAll<T: Decodable>(from table: String) async throws -> [T] {
        do {
            let result: [T] = try await Supabase.shared.client
                .from(table)
                .select("*")
                .execute()
                .value
            return result
        } catch {
            throw error
        }
    }

    func fetchByID<T: Decodable>(from table: String, id: Int) async throws -> T {
        do {
            let result: T = try await Supabase.shared.client
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

    func fetchByField<T: Decodable>(from table: String, field: String, value: UUID) async throws -> [T] {
        do {
            let result: [T] = try await Supabase.shared.client
                .from(table)
                .select()
                .eq(field, value: value)
                .execute()
                .value
            return result
        } catch {
            throw error
        }
    }

    func insert<T: Encodable>(_ item: T, into table: String) async throws {
        do {
            try await Supabase.shared.client
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
            try await Supabase.shared.client
                .from(table)
                .update(item)
                .eq("id", value: id)
                .execute()
            print("DEBUG: Item updated successfully in \(table).")
        } catch {
            throw error
        }
    }

    func delete(from table: String, id: Int) async throws {
        do {
            try await Supabase.shared.client
                .from(table)
                .delete()
                .eq("id", value: id)
                .execute()
            print("DEBUG: Item deleted successfully from \(table).")
        } catch {
            throw error
        }
    }
}

protocol ListingServiceProtocol {
    func fetchPaginatedListings(from: Int, to: Int) async throws -> [Listing]
    func fetchListing(id: Int) async throws -> Listing
    func fetchMakeModels() async throws -> [CarMake]
    func fetchUserListings(userID: UUID) async throws -> [Listing]
    func createListing(_ listing: Listing) async throws
    func updateListing(_ listing: Listing) async throws
    func deleteListing(at id: Int) async throws
}

struct ListingService: ListingServiceProtocol {
    private let databaseService: DatabaseServiceProtocol
    
    init(databaseService: DatabaseServiceProtocol = DatabaseService()) {
        self.databaseService = databaseService
    }
    
    func fetchPaginatedListings(from: Int, to: Int) async throws -> [Listing] {
        try await databaseService.fetchPagination(from: "car_listing", orderBy: "created_at", ascending: false, from: from, to: to)
    }
    
    func fetchListing(id: Int) async throws -> Listing {
        try await databaseService.fetchByID(from: "car_listing", id: id)
    }
    
    func fetchMakeModels() async throws -> [CarMake] {
        try await databaseService.fetchAll(from: "car_make")
    }
    
    func fetchUserListings(userID: UUID) async throws -> [Listing] {
        try await databaseService.fetchByField(from: "car_listing", field: "user_id", value: userID)
    }
    
    func createListing(_ listing: Listing) async throws {
        try await databaseService.insert(listing, into: "car_listing")
    }
    
    func updateListing(_ listing: Listing) async throws {
        guard let id = listing.id else {
            print("DEBUG: Listing ID is missing.")
            return
        }
        try await databaseService.update(listing, in: "car_listing", id: id)
    }
    
    func deleteListing(at id: Int) async throws {
        try await databaseService.delete(from: "car_listing", id: id)
    }
}
