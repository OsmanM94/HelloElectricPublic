//
//  CompanyHouse.swift
//  Clin
//
//  Created by asia on 11/09/2024.
//

import Foundation


enum CompaniesHouseError: Error {
    case invalidURL
    case noData
    case decodingError
    case apiError(String)
}

struct CompaniesHouseAPI {
    private let apiKey = "46636fa5-3467-4f28-87ab-4fa6c0dfd541"
    private let baseURL = "https://api.company-information.service.gov.uk"
    
    func getBasicCompanyInformation(companyNumber: String) async throws -> [String: Any] {
        let endpoint = "/company/\(companyNumber)"
        guard let url = URL(string: baseURL + endpoint) else {
            throw CompaniesHouseError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add API Key to the request header with Basic Authentication
        let credentials = "\(apiKey):" // API key only, followed by a colon
        guard let credentialData = credentials.data(using: .utf8)?.base64EncodedString() else {
            throw CompaniesHouseError.invalidURL
        }
        request.addValue("Basic \(credentialData)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CompaniesHouseError.apiError("Invalid response")
        }
        
        switch httpResponse.statusCode {
        case 200:
            guard let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                throw CompaniesHouseError.decodingError
            }
            return jsonResult
        case 401:
            throw CompaniesHouseError.apiError("Unauthorized: Invalid API key")
        case 404:
            throw CompaniesHouseError.apiError("Company not found")
        default:
            throw CompaniesHouseError.apiError("API error: \(httpResponse.statusCode)")
        }
    }
}

