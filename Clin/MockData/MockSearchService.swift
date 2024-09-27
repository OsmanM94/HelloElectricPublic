//
//  MockSearchService.swift
//  Clin
//
//  Created by asia on 22/08/2024.
//

import Foundation

final class MockSearchService: SearchServiceProtocol {
    func searchFilteredItems(filters: [String : Any], from: Int, to: Int) async throws -> [Listing] {
        return MockListingService.sampleData
    }
    
    func searchWithPaginationAndFilter(or: String, from: Int, to: Int) async throws -> [Listing] {
        return MockListingService.sampleData
    }
    
    private let mockEVModels: [EVModels] = [
          EVModels(id: 1, make: "Tesla", models: ["Model S", "Model 3"]),
          EVModels(id: 2, make: "Nissan", models: ["Leaf"])
      ]
      
      private let mockCities: [Cities] = [
          Cities(id: 1, city: "London"),
          Cities(id: 2, city: "Manchester")
      ]
      
      private let mockEVFeatures: [EVFeatures] = [
          EVFeatures(
              id: 1,
              bodyType: ["Sedan"],
              yearOfManufacture: ["2020"],
              range: ["400 km"],
              homeChargingTime: ["8 hours"],
              publicChargingTime: ["1 hour"],
              batteryCapacity: ["100 kWh"],
              condition: ["New"],
              regenBraking: ["Yes"],
              warranty: ["5 years"],
              serviceHistory: ["Full"],
              owners: ["1"],
              powerBhp: ["450"],
              colours: ["Red", "Blue"]
          )
      ]
      
      // Mock implementations of the SearchServiceProtocol functions
      func loadModels() async throws -> [EVModels] {
          return mockEVModels
      }
      
      func loadCities() async throws -> [Cities] {
          return mockCities
      }
      
      func loadEVfeatures() async throws -> [EVFeatures] {
          return mockEVFeatures
      }
}
