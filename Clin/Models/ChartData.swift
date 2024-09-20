//
//  FuelRegistration.swift
//  Clin
//
//  Created by asia on 30/08/2024.
//

import Foundation

struct ChartData: Identifiable, Codable {
    var id: Int
    let fuelCategory: String
    let periodType: String
    let registrationCount: Double
    let periodLabel: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case fuelCategory = "fuel_category"
        case periodType = "period_type"
        case registrationCount = "registration_count"
        case periodLabel = "period_label"
    }
}

