//
//  FavouriteCell.swift
//  Clin
//
//  Created by asia on 25/07/2024.
//

import SwiftUI

struct FavouriteCell: View {
    let favourite: Favourite
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                if let firstImageURL = favourite.thumbnailsURL.first {
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
                Text("\(favourite.make) \(favourite.model)")
                    .font(.headline)
                    .lineLimit(2, reservesSpace: true)
                Text("\(favourite.condition)")
                    .font(.subheadline)
                Text("\(favourite.mileage, format: .number) miles")
                    .font(.subheadline)
                Text(favourite.price, format: .currency(code: Locale.current.currency?.identifier ?? "GBP"))
                    .font(.subheadline)
            }
            .padding(.leading, 5)
        }
    }
}

#Preview {
    FavouriteCell(favourite: MockFavouriteService.sampleData[0])
}
