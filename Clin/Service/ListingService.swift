//
//  CarListingService.swift
//  Clin
//
//  Created by asia on 24/06/2024.
//

import Foundation


final class ListingService {
    static let shared = ListingService()
    
    private let supabase = SupabaseService.shared.client
    
    private init() {}
    
    func fetchListings() async throws -> [Listing] {
        do {
            let listings: [Listing] = try await supabase
                .from("car_listing")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value
            return listings
        } catch {
            print("Error fetching listings: \(error)")
            throw error
        }
    }
    
    func fetchUserListings(userID: UUID) async throws -> [Listing] {
        do {
            let listings: [Listing] = try await supabase
                .from("car_listing")
                .select()
                .eq("user_id", value: userID)
                .order("created_at", ascending: false)
                .execute()
                .value
            return listings
        } catch {
            print("Error fetching user listings: \(error)")
            throw error
        }
    }
    
    func createListing(imagesURL: [URL], make: String, model: String, condition: String, mileage: Double, yearOfManufacture: String, price: Double, description: String, range: String, colour: String, publicChargingTime: String, homeChargingTime: String, batteryCapacity: String, powerBhp: String, regenBraking: String, warranty: String, serviceHistory: String, numberOfOwners: String, userID: UUID) async throws {
        
        do {
            let listing = Listing(
                createdAt: Date(),
                imagesURL: imagesURL,
                make: make,
                model: model,
                condition: condition,
                mileage: mileage,
                yearOfManufacture: yearOfManufacture,
                price: price,
                description: description,
                range: range,
                colour: colour,
                publicChargingTime: publicChargingTime,
                homeChargingTime: homeChargingTime,
                batteryCapacity: batteryCapacity,
                powerBhp: powerBhp,
                regenBraking: regenBraking,
                warranty: warranty,
                serviceHistory: serviceHistory,
                numberOfOwners: numberOfOwners,
                userID: userID
            )
            try await supabase
                .from("car_listing")
                .insert(listing)
                .execute()
            print("Listing created successfully.")
        } catch {
            print("Error creating listing: \(error)")
            throw error
        }
    }
    
    func updateListing(_ listing: Listing, make: String) async throws {
        guard let id = listing.id else {
            print("Listing ID is missing.")
            return
        }
        
        var toUpdate = listing
        toUpdate.make = make
        
        do {
            try await supabase
                .from("car_listing")
                .update(toUpdate)
                .eq("id", value: id)
                .execute()
            print("Listing updated successfully")
            
        } catch {
            print("Error updating listing: \(error)")
            throw error
        }
    }
    
    func deleteListing(at id: Int) async throws {
        do {
            try await supabase
                .from("car_listing")
                .delete()
                .eq("id", value: id)
                .execute()
            
        } catch {
            print("Error deleting listing: \(error)")
            throw error
        }
    }
}
