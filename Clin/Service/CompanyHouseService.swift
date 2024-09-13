//
//  CompanyHouseService.swift
//  Clin
//
//  Created by asia on 12/09/2024.
//

import Foundation
import Factory

struct CompanyInfo: Decodable {
    let companyName: String
    let companyNumber: String
    let companyStatus: String

    enum CodingKeys: String, CodingKey {
        case companyName = "company_name"
        case companyNumber = "company_number"
        case companyStatus = "company_status"
    }
}

protocol CompaniesHouseServiceProtocol {
    func loadCompanyDetails(companyNumber: String) async throws -> CompanyInfo
}

final class CompaniesHouseService: CompaniesHouseServiceProtocol {
    @Injected(\.httpDataDownloader) var httpDataDownloader: HTTPDataDownloaderProtocol

    private let apiKey = "1c1054e0-d0ac-4bb4-bbbd-5ba91352b0a3"
    private let baseURL = "https://api.company-information.service.gov.uk/company"
    
    func loadCompanyDetails(companyNumber: String) async throws -> CompanyInfo {
        let endpoint = "\(baseURL)/\(companyNumber)"
        let headers = [
            "Authorization": "Basic \(apiKey.toBase64())",
            "Content-Type": "application/json"
        ]
        
        return try await httpDataDownloader.loadData(
            as: CompanyInfo.self,
            endpoint: endpoint,
            headers: headers
        )
    }
}


