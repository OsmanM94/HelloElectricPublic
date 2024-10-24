//
//  Station.swift
//  Clin
//
//  Created by asia on 29/08/2024.
//

import Foundation
import MapKit

struct Station: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let coordinate: CLLocationCoordinate2D
    let connections: [Connection]
    let operatorInfo: OperatorInfo?
    
    var hasFastCharging: Bool {
        connections.contains { $0.level?.isFastChargeCapable == true }
    }
    
    var isPrivateOperator: Bool {
        operatorInfo?.isPrivateIndividual ?? false
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Station, rhs: Station) -> Bool {
        lhs.id == rhs.id
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case addressInfo = "AddressInfo"
        case connections = "Connections"
        case operatorInfo = "OperatorInfo"
    }

    enum AddressInfoKeys: String, CodingKey {
        case title = "Title"
        case latitude = "Latitude"
        case longitude = "Longitude"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)

        let addressContainer = try container.nestedContainer(keyedBy: AddressInfoKeys.self, forKey: .addressInfo)
        name = try addressContainer.decode(String.self, forKey: .title)
        
        if let latitude = try? addressContainer.decode(Double.self, forKey: .latitude),
           let longitude = try? addressContainer.decode(Double.self, forKey: .longitude) {
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            // Provide a default coordinate or throw an error
            coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
  
        connections = try container.decode([Connection].self, forKey: .connections)
        
        operatorInfo = try container.decodeIfPresent(OperatorInfo.self, forKey: .operatorInfo)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        
        var addressContainer = container.nestedContainer(keyedBy: AddressInfoKeys.self, forKey: .addressInfo)
        try addressContainer.encode(name, forKey: .title)
        try addressContainer.encode(coordinate.latitude, forKey: .latitude)
        try addressContainer.encode(coordinate.longitude, forKey: .longitude)
        
        try container.encode(connections, forKey: .connections)
        try container.encodeIfPresent(operatorInfo, forKey: .operatorInfo)
    }
}

// MARK: - Connection
struct Connection: Codable {
    let level: Level?
    let powerKW: Double?
    let statusType: StatusType?
    let connectionType: ConnectionType?
    

    enum CodingKeys: String, CodingKey {
        case level = "Level"
        case powerKW = "PowerKW"
        case statusType = "StatusType"
        case connectionType = "ConnectionType"
    }
}

// MARK: - Level
struct Level: Codable {
    let isFastChargeCapable: Bool?
    let title: String? // eg. 40KW or higher
    
    enum CodingKeys: String, CodingKey {
        case isFastChargeCapable = "IsFastChargeCapable"
        case title = "Title"
    }
}

// MARK: - Operator info
struct OperatorInfo: Codable {
    let isPrivateIndividual: Bool? /// eg. Private / Public
    
    enum CodingKeys: String, CodingKey {
        case isPrivateIndividual = "IsPrivateIndividual"
    }
}

// MARK: - StatusType
struct StatusType: Codable {
    let title: String? /// eg. "Operational"

    enum CodingKeys: String, CodingKey {
        case title = "Title"
    }
}

// MARK: - ConnectionType
struct ConnectionType: Codable {
    let title: String?

    enum CodingKeys: String, CodingKey {
        case title = "Title"
    }
}


