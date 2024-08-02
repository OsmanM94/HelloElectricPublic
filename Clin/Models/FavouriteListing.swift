//
//  FavouriteListing.swift
//  Clin
//
//  Created by asia on 25/07/2024.
//

import Foundation

struct FavouriteListing: Identifiable {
    var id: UUID = UUID()
    let listing: Listing
}

extension FavouriteListing {
    static var sampleData: [FavouriteListing] = MockListingService.sampleData.map { FavouriteListing(listing: $0) }
}
