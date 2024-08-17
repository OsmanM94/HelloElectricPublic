//
//  DVLAService.swift
//  Clin
//
//  Created by asia on 25/06/2024.
//

import Foundation

struct DvlaService: DvlaServiceProtocol {
    private let httpDownloader: HTTPDataDownloaderProtocol
    private let apiKey = "32ajeg6zif8hoBN6pASIJ93uAzx9erA34jAoyLxA"
    private let baseURL = "https://driver-vehicle-licensing.api.gov.uk/vehicle-enquiry/v1/vehicles"
    
    init(httpDownloader: HTTPDataDownloaderProtocol) {
        self.httpDownloader = httpDownloader
    }
    
    func fetchCarDetails(registrationNumber: String) async throws -> Dvla {
        let parameters = ["registrationNumber": registrationNumber]
        let headers = [
            "x-api-key": apiKey,
            "Content-Type": "application/json"
        ]
        
        return try await httpDownloader.postData(
            as: Dvla.self,
            to: baseURL,
            body: parameters,
            headers: headers
        )
    }
}


