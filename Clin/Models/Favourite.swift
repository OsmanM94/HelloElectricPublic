//
//  FavouriteListing.swift
//  Clin
//
//  Created by asia on 25/07/2024.
//

import Foundation

struct Favourite: Identifiable {
    var id: UUID = UUID()
    let listing: Listing
}

extension Favourite {
    static var sampleData: [Favourite] = MockListingService.sampleData.map { Favourite(listing: $0) }
}
