//
//  NewsDisclaimer.swift
//  Clin
//
//  Created by asia on 11/09/2024.
//

import SwiftUI

struct NewsDisclaimer: View {
    var body: some View {
        VStack {
            Text("Disclaimer")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("The news articles displayed in this app are sourced from various third-party websites and news outlets. We are not responsible for the content created by these sources. The information is downloaded from an API and may contain diverse perspectives on electric vehicles. Always verify information from multiple sources.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.yellow.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                )
        }
        .padding()
    }
}

#Preview {
    NewsDisclaimer()
}
