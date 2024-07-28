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
                if let firstImageURL = listing.imagesURL.first {
                    ImageLoader(url: firstImageURL, contentMode: .fill)
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
            .overlay(alignment: .topTrailing) {
                AddToFavouritesButton(listing: listing)
            }
            
            VStack(alignment: .leading) {
                Text("\(listing.make) \(listing.model)")
                    .font(.headline)
                    .lineLimit(2, reservesSpace: true)
                Text("\(listing.condition)")
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
    ListingCell(listing: Listing(
           id: 1,
           createdAt: Date(),
           imagesURL: [URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/avatars/15ECE008-ABF5-43CF-8DAF-1A26A342FFAF.jpeg?download=")!],
           make: "Tesla",
           model: "Model S supercharger 2024",
           condition: "Used",
           mileage: 100000,
           yearOfManufacture: "2023",
           price: 8900,
           description: "A great electric vehicle with long range.",
           range: "396 miles",
           colour: "Red",
           publicChargingTime: "1 hour",
           homeChargingTime: "10 hours",
           batteryCapacity: "100 kWh",
           powerBhp: "1020",
           regenBraking: "Yes",
           warranty: "4 years",
           serviceHistory: "Full",
           numberOfOwners: "1",
           userID: UUID()
    ))
    .environmentObject(FavouriteViewModel())
}



