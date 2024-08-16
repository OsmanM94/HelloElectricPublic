//
//  CarMake.swift
//  Clin
//
//  Created by asia on 15/08/2024.
//

import Foundation

struct CarMake: Identifiable, Codable {
    var id: Int?
    var make: String
    var models: [String]
}
