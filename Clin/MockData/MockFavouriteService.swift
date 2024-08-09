//
//  MockFavouriteService.swift
//  Clin
//
//  Created by asia on 09/08/2024.
//

import Foundation

struct MockFavouriteService: FavouriteServiceProtocol {
    
    static let mockUserID = UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000")!
    
    // Sample data for Favourite
    static var sampleData: [Favourite] = [
        Favourite(
            id: 1,
            userID: mockUserID,
            listingID: 1,
            imagesURL: [URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/tesla2.jpg")!], thumbnailsURL: [URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/tesla2.jpg")!],
            make: "Tesla",
            model: "Model S supercharger 2024",
            condition: "Used",
            mileage: 100000,
            price: 8900
        ),
        Favourite(
            id: 2,
            userID: mockUserID,
            listingID: 2,
            imagesURL: [URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/tesla1.jpg")!], thumbnailsURL: [URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/tesla1.jpg")!],
            make: "Mercedes",
            model: "Mercedes-Benz EQA Class",
            condition: "Used",
            mileage: 120000,
            price: 9900
        ),
        Favourite(
            id: 3,
            userID: mockUserID,
            listingID: 3,
            imagesURL:[URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/tesla3.jpg")!], thumbnailsURL: [URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/tesla3.jpg")!],
            make: "BMW",
            model: "i4 M50",
            condition: "New",
            mileage: 5000,
            price: 70000
        )
    ]
    
    func fetchUserFavourites(userID: UUID) async throws -> [Favourite] {
        return MockFavouriteService.sampleData.filter { $0.userID == userID }
    }
    
    func addToFavorites(_ favourite: Favourite) async throws {
        MockFavouriteService.sampleData.append(favourite)
    }
    
    func removeFromFavorites(_ favourite: Favourite, for userID: UUID) async throws {
        MockFavouriteService.sampleData.removeAll { $0.id == favourite.id && $0.userID == userID }
    }
}
