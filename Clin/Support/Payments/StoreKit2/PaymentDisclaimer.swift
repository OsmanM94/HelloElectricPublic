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
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                )
            HStack {
                Image(systemName: termsAcknowledged ? "checkmark.square.fill" : "square")
                    .foregroundColor(termsAcknowledged ? .tabColour : .secondary)
                Text("I acknowledge that this purchase is non-refundable")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
