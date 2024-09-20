//
//  ChartDisclaimer.swift
//  Clin
//
//  Created by asia on 11/09/2024.
//

import SwiftUI

struct ChartDisclaimer: View {
    var body: some View {
        
        DisclosureGroup("Disclaimer") {
            disclaimerContent
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding()
        
    }
    
    private var disclaimerContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("The data presented in this chart is sourced from the Society of Motor Manufacturers and Traders (SMMT) in the UK. While we strive for accuracy, this information may not reflect real-time market conditions and should be used for general informational purposes only. For the most up-to-date and detailed information, please refer to the official SMMT reports.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
        )
        
    }
}

#Preview {
    ChartDisclaimer()
}
