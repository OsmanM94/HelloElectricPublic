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
        HStack(spacing: 10) {
            imageView
            
            VStack(alignment: .leading, spacing: 10) {
                Text("\(favourite.make) \(favourite.model)")
                    .font(.headline)
                    .lineLimit(2, reservesSpace: false)
                
                HStack(spacing: 8) {
                    Label(favourite.condition, systemImage: "car")
                    Label {
                        Text("\(favourite.mileage, format: .number) miles")
                    } icon: {
                        Image(systemName: "speedometer")
                    }

                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                
                Text(favourite.price, format: .currency(code: Locale.current.currency?.identifier ?? "GBP"))
                    .font(.subheadline)
            }
        }
        .fontDesign(.rounded).bold()
        .padding()
    }
    
    
    private var imageView: some View {
        Group {
            if let firstImageURL = favourite.thumbnailsURL.first {
                ImageLoader(url: firstImageURL, contentMode: .fill, targetSize: CGSize(width: 80, height: 80))
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Rectangle()
                    .foregroundStyle(.gray.opacity(0.5))
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        ProgressView()
                            .scaleEffect(1.2)
                    }
            }
        }
    }
}

#Preview {
    FavouriteCell(favourite: MockFavouriteService.sampleData[0])
}
