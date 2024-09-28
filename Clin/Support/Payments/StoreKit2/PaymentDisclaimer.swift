//
//  PaymentDisclaimer.swift
//  Clin
//
//  Created by asia on 10/09/2024.
//

import SwiftUI

struct PaymentDisclaimer: View {
    @Binding var termsAcknowledged: Bool
    
    var body: some View {
        VStack {
            Text("This is a one-time, non-refundable purchase. The promotion will last for 2 weeks from the time of purchase.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.yellow.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
               
            HStack {
                Image(systemName: termsAcknowledged ? "checkmark.square.fill" : "square")
                    .foregroundStyle(termsAcknowledged ? .tabColour : .secondary)
                Text("I acknowledge that this purchase is non-refundable")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .onTapGesture {
                termsAcknowledged.toggle()
            }
        }
    }
}

#Preview {
    PaymentDisclaimer(termsAcknowledged: .constant(false))
}
