//
//  ApprovedFeatureRow.swift
//  Clin
//
//  Created by asia on 29/09/2024.
//

import SwiftUI

struct ApprovedFeatureRow: View {
    let feature: ApprovedFeature
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(feature.name)
                .font(.headline)
            Text(feature.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Expected: \(feature.eta)")
                .font(.caption)
                .foregroundStyle(.tabColour)
        }
        .padding()
    }
}

#Preview {
    ApprovedFeatureRow(feature: ApprovedFeature(name: "Chat messaging", description: "Communicate directly with sellers within the app.", eta: " Jan - Mar 2025"))
}
