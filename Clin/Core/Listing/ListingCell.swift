//
//  ListingCell.swift
//  Clin
//
//  Created by asia on 23/07/2024.
//

import SwiftUI

struct ListingCell: View {
    @State private var startTimer: Date = Date()
    var listing: Listing
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                if let firstImageURL = listing.imagesURL.first  {
                    ImageLoader(url: firstImageURL, contentMode: .fill)
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
            
            VStack(alignment: .leading) {
                Text("\(listing.make) \(listing.model)")
                    .font(.headline)
                    .lineLimit(2, reservesSpace: false)
                Text("\(listing.condition)")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                Text("\(listing.mileage, format: .number) miles")
                    .font(.subheadline)
                Text(listing.price, format: .currency(code: Locale.current.currency?.identifier ?? "GBP"))
                    .font(.subheadline)
                Text("added \(timeElapsedString(since: listing.createdAt))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }  
            .padding(.leading, 5)
        }
        .onAppear {
            startListingTimer()
        }
    }
    
    fileprivate func startListingTimer() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            startTimer = Date()
        }
    }
}

#Preview {
    ListingCell(listing: MockListingService.sampleData[0])
        .environmentObject(FavouriteViewModel())
}



