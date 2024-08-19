//
//  DVLAService.swift
//  Clin
//
//  Created by asia on 25/06/2024.
//

import Foundation
import Factory

final class DvlaService: DvlaServiceProtocol {
    @Injected(\.httpDataDownloader) var httpDataDownloader: HTTPDataDownloaderProtocol
        
    private let apiKey = "32ajeg6zif8hoBN6pASIJ93uAzx9erA34jAoyLxA"
    private let baseURL = "https://driver-vehicle-licensing.api.gov.uk/vehicle-enquiry/v1/vehicles"
    
    func fetchCarDetails(registrationNumber: String) async throws -> Dvla {
        let parameters = ["registrationNumber": registrationNumber]
        let headers = [
            "x-api-key": apiKey,
            "Content-Type": "application/json"
        ]
        
        return try await httpDataDownloader.postData(
            as: Dvla.self,
            to: baseURL,
            body: parameters,
            headers: headers
        )
    }
}


