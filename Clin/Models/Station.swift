//
//  Station.swift
//  Clin
//
//  Created by asia on 29/08/2024.
//

import Foundation
import MapKit

struct Station: Identifiable, Decodable, Hashable {
    let id: Int
    let name: String
    let coordinate: CLLocationCoordinate2D
    
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
    }

    enum AddressInfoKeys: String, CodingKey {
        case title = "Title"
        case latitude = "Latitude"
        case longitude = "Longitude"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode ID as an Int
        id = try container.decode(Int.self, forKey: .id)

        let addressContainer = try container.nestedContainer(keyedBy: AddressInfoKeys.self, forKey: .addressInfo)
        name = try addressContainer.decode(String.self, forKey: .title)
        
        // Safely decode latitude and longitude
        if let latitude = try? addressContainer.decode(Double.self, forKey: .latitude),
           let longitude = try? addressContainer.decode(Double.self, forKey: .longitude) {
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            // Provide a default coordinate or throw an error
            coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
            print("Warning: Invalid coordinates for charger \(name)")
        }
    }
}
