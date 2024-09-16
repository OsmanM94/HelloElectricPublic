//
//  EVDetailsSplashView.swift
//  Clin
//
//  Created by asia on 16/09/2024.
//

import SwiftUI

struct EVDetailsSplashView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            noImagesAvailable
                .padding(.bottom)
            
            infoRow("Acceleration (0-62 mph)", "5 sec")
            infoRow("Top Speed", "100 mph")
            infoRow("Total Power", "100 kWh")
            infoRow("Torque", "350")
            infoRow("Drive", "Front")
            
            infoRow("Acceleration (0-62 mph)", "5 sec")
            infoRow("Top Speed", "100 mph")
            infoRow("Total Power", "100 kWh")
            infoRow("Torque", "350")
            infoRow("Drive", "Front")
        }
        .redacted(reason: .placeholder)
        Spacer()
    }
    
    private var noImagesAvailable: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(height: 300)
            .overlay(
                ProgressView()
            )
    }
    
    private func infoRow(_ title: String, _ value: String?) -> some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
            Spacer()
            Text(value ?? "N/A")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    EVDetailsSplashView()
}
