//
//  Disclaimer.swift
//  Clin
//
//  Created by asia on 10/09/2024.
//

import SwiftUI

struct ListingDisclaimerView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Disclaimer")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("The information provided about this vehicle, including specifications, features, and condition, is based on the seller's description and available data. While we strive for accuracy, these details are estimates and may not be completely accurate or up-to-date. Buyers are responsible for verifying all information and conducting their own inspections before making a purchase decision. HelloElectric does not guarantee the accuracy of this information and is not liable for any discrepancies or issues that may arise.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
        )
        .padding(.vertical)
    }
}

#Preview {
    ListingDisclaimerView()
}
