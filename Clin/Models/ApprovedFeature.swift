//
//  ApprovedFeature.swift
//  Clin
//
//  Created by asia on 29/09/2024.
//

import Foundation

struct ApprovedFeature: Identifiable, Codable, Hashable {
    var id: Int?
    let name: String
    let description: String
    let eta: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case eta
    }
}
