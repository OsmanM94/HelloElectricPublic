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
                if let firstImageURL = listing.thumbnailsURL.first {
                    ImageLoader(url: firstImageURL, contentMode: .fill, targetSize: CGSize(width: 120, height: 120))
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.5))
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay { ProgressView().scaleEffect(1.2) }
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
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                Text("\(listing.mileage, format: .number) miles")
                    .font(.subheadline)
                Text(listing.price, format: .currency(code: Locale.current.currency?.identifier ?? "GBP").precision(.fractionLength(0)))
                    .font(.subheadline)
            }
            .padding(.leading, 5)
        }
    }
}

#Preview {
    UserListingCell(listing: MockListingService.sampleData[0])
}
