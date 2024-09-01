//
//  MockListingService.swift
//  Clin
//
//  Created by asia on 02/08/2024.
//

import Foundation

struct MockListingService: ListingServiceProtocol {
    
    static let mockUserID = UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000")!
    
    static var modelsSample: [EVModels] = [EVModels(id: 1, make: "Tesla", models: ["Model2","Model3"])]
    
    static var citiesSample: [Cities] = [Cities(id: 1, city: "London")]
    
    static var evFeatures: [EVFeatures] = [EVFeatures(id: 1, bodyType: ["SUV"], yearOfManufacture: ["2024"], range: ["300"], homeChargingTime: ["1hour"], publicChargingTime: ["30"], batteryCapacity: ["50kWh"], condition: ["Used"], regenBraking: ["Yes"], warranty: ["Yes"], serviceHistory: ["Yes"], owners: ["4"], powerBhp: ["450"], colours: ["White"])]
    
    static var sampleData: [Listing] = [
        Listing(
            id: 1,
            createdAt: Date(),
            imagesURL: [URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/tesla2.jpg")!,URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/tesla1.jpg")!,URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/tesla3.jpg")!], thumbnailsURL: [URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/tesla2.jpg")!],
            make: "Tesla",
            model: "Model S supercharger",
            bodyType: "SUV",
            condition: "Used",
            mileage: 100000,
            location: "London",
            yearOfManufacture: "2023",
            price: 8900,
            phoneNumber: "07466861602",
            textDescription: "A great electric vehicle with long range.",
            range: "396 miles",
            colour: "Red",
            publicChargingTime: "1 hour",
            homeChargingTime: "10 hours",
            batteryCapacity: "100 kWh",
            powerBhp: "1020",
            regenBraking: "Yes",
            warranty: "4 years",
            serviceHistory: "Full",
            numberOfOwners: "1",
            userID: mockUserID,
            isPromoted: true
        ),
        Listing(
            id: 2,
            createdAt: Date(),
            imagesURL: [URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/tesla1.jpg")!], thumbnailsURL: [URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/tesla1.jpg")!],
            make: "Mercedes",
            model: "Mercedes-Benz EQA Class",
            bodyType: "Saloon",
            condition: "Used",
            mileage: 120000,
            location: "Peterborough",
            yearOfManufacture: "2024",
            price: 9900,
            phoneNumber: "07466861602",
            textDescription: "A great electric vehicle with long range.",
            range: "396 miles",
            colour: "Red",
            publicChargingTime: "1 hour",
            homeChargingTime: "10 hours",
            batteryCapacity: "100 kWh",
            powerBhp: "1020",
            regenBraking: "Yes",
            warranty: "4 years",
            serviceHistory: "Full",
            numberOfOwners: "1",
            userID: mockUserID,
            isPromoted: true
        ),
        Listing(
            id: 3,
            createdAt: Date(),
            imagesURL: [URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/tesla3.jpg")!], thumbnailsURL: [URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/tesla3.jpg")!],
            make: "BMW",
            model: "i4 M50",
            bodyType: "Pickup",
            condition: "New",
            mileage: 5000,
            location: "Leicester",
            yearOfManufacture: "2022",
            price: 70000,
            phoneNumber: "07466861602",
            textDescription: "A sleek and powerful electric sedan with excellent performance.",
            range: "300 miles",
            colour: "Blue",
            publicChargingTime: "45 mins",
            homeChargingTime: "9 hours",
            batteryCapacity: "80 kWh",
            powerBhp: "536",
            regenBraking: "Yes",
            warranty: "3 years",
            serviceHistory: "Full",
            numberOfOwners: "1",
            userID: mockUserID,
            isPromoted: false
        ),
        Listing(
            id: 4,
            createdAt: Date(),
            imagesURL: [URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/tesla4.jpg")!], thumbnailsURL: [URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/tesla4.jpg")!],
            make: "Audi",
            model: "e-tron GT",
            bodyType: "Truck",
            condition: "Used",
            mileage: 25000,
            location: "Wisbech",
            yearOfManufacture: "2021",
            price: 85000,
            phoneNumber: "07466861602",
            textDescription: "An electric grand tourer with stunning design and performance.",
            range: "238 miles",
            colour: "Black",
            publicChargingTime: "30 mins",
            homeChargingTime: "8 hours",
            batteryCapacity: "93 kWh",
            powerBhp: "637",
            regenBraking: "Yes",
            warranty: "4 years",
            serviceHistory: "Full",
            numberOfOwners: "2",
            userID: mockUserID,
            isPromoted: false
        ),
        Listing(
            id: 5,
            createdAt: Date(),
            imagesURL: [URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/tesla5.jpg")!], thumbnailsURL: [URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/mock_data/tesla5.jpg")!],
            make: "Nissan",
            model: "Leaf",
            bodyType: "Estate",
            condition: "Used",
            mileage: 80000,
            location: "March",
            yearOfManufacture: "2020",
            price: 15000,
            phoneNumber: "07466861602",
            textDescription: "A reliable and affordable electric hatchback.",
            range: "150 miles",
            colour: "White",
            publicChargingTime: "1 hour",
            homeChargingTime: "7 hours",
            batteryCapacity: "40 kWh",
            powerBhp: "147",
            regenBraking: "Yes",
            warranty: "2 years",
            serviceHistory: "Full",
            numberOfOwners: "1",
            userID: mockUserID,
            isPromoted: false
        )
    ]
    
    func loadPaginatedListings(from: Int, to: Int) async throws -> [Listing] {
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        return MockListingService.sampleData
    }
    
    func loadListing(id: Int) async throws -> Listing {
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        return MockListingService.sampleData[0]
    }
    
    func loadModels() async throws -> [EVModels] {
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        return MockListingService.modelsSample
    }
    
    func loadLocations() async throws -> [Cities] {
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        return MockListingService.citiesSample
    }
    
    func loadEVfeatures() async throws -> [EVFeatures] {
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        return MockListingService.evFeatures
    }
    
    func loadUserListings(userID: UUID) async throws -> [Listing] {
        return MockListingService.sampleData.filter { $0.userID == userID }
    }
    
    func createListing(_ listing: Listing) async throws {
        MockListingService.sampleData.append(listing)
    }
    
    func updateListing(_ listing: Listing) async throws {
        if let index = MockListingService.sampleData.firstIndex(where: { $0.id == listing.id }) {
            MockListingService.sampleData[index] = listing
        }
    }
    
    func deleteListing(at id: Int) async throws {
        MockListingService.sampleData.removeAll { $0.id == id }
    }
}
