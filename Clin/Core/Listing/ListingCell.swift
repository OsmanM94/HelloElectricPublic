//
//  ListingCell.swift
//  Clin
//
//  Created by asia on 23/07/2024.
//

import SwiftUI

struct ListingCell: View {
    var listing: Listing
    
    var body: some View {
        HStack {
            // Display the first image using SDWebImage
            if let firstImageURL = listing.imagesURL.first {
                ImageLoader(url: firstImageURL, contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.5))
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        ProgressView()
                            .scaleEffect(1.2)
                    }
            }
            
            VStack(alignment: .leading) {
                Text("\(listing.make) \(listing.model)")
                    .font(.headline)
                Text(listing.yearOfManufacture)
                    .font(.subheadline)
                Text("Condition: \(listing.condition)")
                    .font(.subheadline)
                Text("Mileage: \(listing.mileage, specifier: "%.0f") miles")
                    .font(.subheadline)
                Text("Price: \(listing.price, specifier: "%.2f") GBP")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
            .padding(.leading, 10)
            
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)).shadow(radius: 2))
    }
}

#Preview {
    ListingCell(listing: Listing(
           id: 1,
           createdAt: Date(),
           imagesURL: [URL(string: "https://jtgcsdqhpqlsrzjzutff.supabase.co/storage/v1/object/public/avatars/15ECE008-ABF5-43CF-8DAF-1A26A342FFAF.jpeg?download=")!],
           make: "Tesla",
           model: "Model S",
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
}



