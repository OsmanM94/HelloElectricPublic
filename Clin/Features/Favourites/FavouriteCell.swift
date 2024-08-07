//
//  FavouriteCell.swift
//  Clin
//
//  Created by asia on 25/07/2024.
//

import SwiftUI

struct FavouriteCell: View {
    let favouriteListing: Favourite
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                if let firstImageURL = favouriteListing.listing.imagesURL.first {
                    ImageLoader(url: firstImageURL, contentMode: .fill, targetSize: CGSize(width: 120, height: 120))
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.5))
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay {
                            ProgressView()
                                .scaleEffect(1.2)
                        }
                }
            }
        
            VStack(alignment: .leading) {
                Text("\(favouriteListing.listing.make) \(favouriteListing.listing.model)")
                    .font(.headline)
                    .lineLimit(2, reservesSpace: true)
                Text("\(favouriteListing.listing.condition)")
                    .font(.subheadline)
                Text("\(favouriteListing.listing.mileage, format: .number) miles")
                    .font(.subheadline)
                Text(favouriteListing.listing.price, format: .currency(code: Locale.current.currency?.identifier ?? "GBP"))
                    .font(.subheadline)
            }
            .padding(.leading, 5)
        }
    }
}

#Preview {
    FavouriteCell(favouriteListing: Favourite(listing: MockListingService.sampleData[0]))
}
