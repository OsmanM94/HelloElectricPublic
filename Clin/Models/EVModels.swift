//
//  CarMake.swift
//  Clin
//
//  Created by asia on 15/08/2024.
//

import Foundation

struct EVModels: Identifiable, Codable, Hashable {
    var id: Int?
    let make: String
    let models: [String]
}

