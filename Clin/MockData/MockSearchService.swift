//
//  MockSearchService.swift
//  Clin
//
//  Created by asia on 22/08/2024.
//

import Foundation

final class MockSearchService: SearchServiceProtocol {
    var mockModels: [EVModels] = []
    var mockCities: [Cities] = []
    var mockEVFeatures: [EVFeatures] = []
    
    func loadModels() async throws -> [EVModels] {
        return mockModels
    }
    
    func loadCities() async throws -> [Cities] {
        return mockCities
    }
    
    func loadEVfeatures() async throws -> [EVFeatures] {
        return mockEVFeatures
    }
}
