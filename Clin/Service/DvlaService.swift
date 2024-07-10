//
//  DVLAService.swift
//  Clin
//
//  Created by asia on 25/06/2024.
//

import Foundation

enum DvlaAPIErrors: Error {
    case invalidURL
    case invalidParameters
    case invalidResponse
}

final class DvlaService {
    private let apiKey = "32ajeg6zif8hoBN6pASIJ93uAzx9erA34jAoyLxA"
    private let baseURL = "https://driver-vehicle-licensing.api.gov.uk/vehicle-enquiry/v1/vehicles"

    func fetchCarDetails(registrationNumber: String) async throws -> Dvla {
        let parameters = ["registrationNumber": registrationNumber]
        
        guard let url = URL(string: baseURL) else {
            throw DvlaAPIErrors.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
            throw DvlaAPIErrors.invalidParameters
        }
        request.httpBody = httpBody
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            let decodedCar = try JSONDecoder().decode(Dvla.self, from: data)
            return decodedCar
        } else {
            throw DvlaAPIErrors.invalidResponse
        }
    }
}


