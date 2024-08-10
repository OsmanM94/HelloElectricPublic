//
//  FavouriteService.swift
//  Clin
//
//  Created by asia on 09/08/2024.
//

import Foundation

struct FavouriteService: FavouriteServiceProtocol {
        
    func fetchUserFavourites(userID: UUID) async throws -> [Favourite] {
        do {
            let favourites: [Favourite] = try await Supabase.shared.client
                .from("favourite_listing")
                .select()
                .eq("user_id", value: userID)
                .order("created_at", ascending: false)
                .execute()
                .value
            return favourites
        } catch {
            throw error
        }
    }
    
    func addToFavorites(_ favourite: Favourite) async throws {
        do {
            try await Supabase.shared.client
                .from("favourite_listing")
                .insert(favourite)
                .execute()
        } catch {
            throw error
        }
    }
    
    func removeFromFavorites(_ favourite: Favourite, for userID: UUID) async throws {
        do {
            try await Supabase.shared.client
                .from("favourite_listing")
                .delete()
                .eq("listing_id", value: favourite.listingID)
                .eq("user_id", value: userID)
                .execute()
        } catch {
            throw error
        }
    }
}

