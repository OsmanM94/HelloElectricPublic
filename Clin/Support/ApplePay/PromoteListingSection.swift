//
//  PromoteListingSection.swift
//  Clin
//
//  Created by asia on 02/09/2024.
//

import SwiftUI

struct PromoteListingSection: View {
    @Binding var isPromoted: Bool
    var onPayment: (Bool) -> Void
    
    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                Text("Promote Listing")
                    .font(.headline)
                
                if isPromoted {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green.gradient)
                        Text("Promoted.")
                        Spacer()
                        Text("Currently promoted.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What you get:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            BenefitRow(icon: "arrow.up.circle.fill", text: "Listing appears at the top (nationwide)")
                            BenefitRow(icon: "tag.fill", text: "Listing badge")
                            BenefitRow(icon: "square.grid.3x3.fill", text: "Exclusive layout")
                        }
                        
                        HStack {
                            Text("£13.99")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("for 2 weeks")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 4)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    
                    PaymentButton { success in
                        isPromoted = success
                        onPayment(success)
                    }
                    .frame(height: 45)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .listRowInsets(EdgeInsets())
            .padding()
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.green.gradient)
                .frame(width: 20)
            Text(text)
        }
    }
}

#Preview {
    PromoteListingSection(isPromoted: .constant(true), onPayment: {_ in })
}
