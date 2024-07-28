//
//  UserListingCell.swift
//  Clin
//
//  Created by asia on 26/07/2024.
//

import SwiftUI

struct UserListingCell: View {
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
                HStack(spacing: 2) {
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundStyle(.green.gradient)
                    Text("Active")
                        .font(.caption2)
                }
                .padding(.trailing, 3)
                .padding(.bottom, 3)
                .padding(.top, 3)
                .padding(.leading, 3)
                .background(.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 5))
                .padding(.all, 4)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text("\(listing.make) \(listing.model)")
                    .font(.headline)
                    .lineLimit(2, reservesSpace: false)
                Text("\(listing.condition)")
                    .font(.subheadline)
                Text("\(listing.mileage, format: .number) miles")
                    .font(.subheadline)
                Text(listing.price, format: .currency(code: Locale.current.currency?.identifier ?? "GBP"))
                    .font(.subheadline)
            }
            .padding(.leading, 5)
        }
    }
}

#Preview {
    UserListingCell(listing: Listing(
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
}
