//
//  ListingCell.swift
//  Clin
//
//  Created by asia on 23/07/2024.
//

import SwiftUI

struct ListingCell: View {
    @State private var timerManager = TimerManager()
    var listing: Listing
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                if let firstImageURL = listing.thumbnailsURL.first  {
                    ImageLoader(url: firstImageURL, contentMode: .fill, targetSize: CGSize(width: 120, height: 120))
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Rectangle()
                        .foregroundStyle(.gray.opacity(0.5))
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            ProgressView()
                                .scaleEffect(1.2)
                        }
                }
            }
            .overlay(alignment: .topTrailing) {
                AddToFavouritesButton(listing: listing)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(listing.make) \(listing.model)")
                    .font(.headline)
                    .lineLimit(2, reservesSpace: false)
                Text("\(listing.condition)")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                Text("\(listing.mileage, format: .number) miles")
                    .font(.subheadline)
                Text(listing.price, format: .currency(code: Locale.current.currency?.identifier ?? "GBP").precision(.fractionLength(0)))
                    .font(.subheadline)
                Text("added \(timeElapsedString(since: listing.createdAt))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }  
            .padding(.leading, 5)
        }
        .onAppear {
            timerManager.startListingTimer(interval: 60)
        }
    }
}

#Preview {
    ListingCell(listing: MockListingService.sampleData[0])
        .environmentObject(FavouriteViewModel())
}



