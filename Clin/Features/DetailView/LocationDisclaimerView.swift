//
//  LocationDisclaimerView.swift
//  Clin
//
//  Created by asia on 11/09/2024.
//

import SwiftUI

struct LocationDisclaimerView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("About the Location")
            
            Text("The location shown represents the general area where the seller is based, not their exact address. This helps protect the seller's privacy while giving you a good idea of the vehicle's location.")
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(width: 300)
    }
}

#Preview {
    LocationDisclaimerView()
}
