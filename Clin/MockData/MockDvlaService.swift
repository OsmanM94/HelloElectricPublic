//
//  MockDvlaService.swift
//  Clin
//
//  Created by asia on 17/08/2024.
//

import Foundation

struct MockDvlaService: DvlaServiceProtocol {
    func loadDetails(registrationNumber: String) async throws -> Dvla {
        return Dvla(fuelType: "ELECTRICITY", registrationNumber: "KM24EDP", yearOfManufacture: 1994, colour: "white", make: "Tesla")
    }
}
