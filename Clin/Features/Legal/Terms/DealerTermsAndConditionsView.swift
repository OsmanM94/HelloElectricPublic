//
//  DealerTermsAndConditionsView.swift
//  Clin
//
//  Created by asia on 11/09/2024.
//

import SwiftUI

struct DealerTermsAndConditionsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Dealer")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("By providing dealer information, you agree to the following terms:")
                        .font(.subheadline)

                    VStack(alignment: .leading, spacing: 10) {
                        bulletPoint("All information provided must be accurate and up-to-date.")
                        bulletPoint("No inappropriate, offensive, or misleading content is allowed.")
                        bulletPoint("Spamming or misuse of the platform is strictly prohibited.")
                        bulletPoint("Violation of these terms may result in permanent account suspension.")
                    }

                    Text("Detailed Terms")
                        .font(.headline)

                    Text("1. Accuracy of Information")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Dealers are responsible for ensuring all provided information is accurate, current, and complete. This includes but is not limited to contact details, vehicle information, and pricing.")

                    Text("2. Content Guidelines")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("All content must be appropriate for a general audience. Offensive, discriminatory, or misleading content is strictly prohibited and will be removed.")

                    Text("3. Fair Use Policy")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Dealers are expected to use the platform fairly. Excessive posting, spamming, or any form of platform manipulation is not allowed.")

                    Text("4. Compliance and Penalties")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Failure to comply with these terms may result in warnings, temporary suspension, or permanent removal from the platform, depending on the severity and frequency of violations.")

                    Text("5. Right to Remove Content")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("We reserve the right to remove any content that violates these terms or that we deem inappropriate for our platform, without prior notice.")

                    Text("By using our dealer services, you acknowledge that you have read, understood, and agree to be bound by these terms and conditions.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top)
                }
                .padding()
            }
            .navigationBarTitle("Terms and Conditions", displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
        }
    }

    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top) {
            Text("•")
            Text(text)
        }
    }
}

#Preview {
    DealerTermsAndConditionsView()
}
