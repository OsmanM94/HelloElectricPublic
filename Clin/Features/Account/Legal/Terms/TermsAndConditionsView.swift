//
//  TermsAndConditionsView.swift
//  Clin
//
//  Created by asia on 08/07/2024.
//

import SwiftUI

struct TermsAndConditionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showDealerDetails: Bool = false

    let generalSections = [
        ("Introduction", "Welcome to our EV marketplace application. By using our app, you agree to comply with and be bound by the following terms and conditions."),
        ("Use of the App", "You agree to use the app only for lawful purposes and in accordance with these terms."),
        ("Listings", "You are responsible for the accuracy of the information provided in your listings."),
        ("Privacy", "Your use of the app is also governed by our Privacy Policy."),
        ("Changes to Terms", "We reserve the right to modify these terms at any time."),
        ("Contact Us", "If you have any questions about these terms, please contact us at support@evmarketplace.com.")
    ]
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 20) {
                // General Terms
                ForEach(generalSections.indices, id: \.self) { index in
                    sectionView(title: "\(index + 1). \(generalSections[index].0)",
                                content: generalSections[index].1)
                }
                
                // Dealer Specific Terms
                dealerTermsSection
                
                // Private Seller Terms
                sectionView(title: "8. Private Sellers",
                            content: "Private sellers are also bound by these terms and conditions. You must ensure that all information provided about your vehicle is accurate and up-to-date.")
                
                Text("By using our services, you acknowledge that you have read, understood, and agree to be bound by these terms and conditions.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top)
            }
            .padding()
        }
        .navigationBarTitle("Terms and Conditions", displayMode: .inline)
    }
    
    private var dealerTermsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("7. Dealer Specific Terms")
                .font(.headline)
            
            Text("Dealers are subject to additional terms and conditions.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            DisclosureGroup("View Dealer Terms", isExpanded: $showDealerDetails) {
                VStack(alignment: .leading, spacing: 10) {
                    bulletPoint("All information provided must be accurate and up-to-date.")
                    bulletPoint("No inappropriate, offensive, or misleading content is allowed.")
                    bulletPoint("Spamming or misuse of the platform is strictly prohibited.")
                    bulletPoint("Violation of these terms may result in permanent account suspension.")
                    
                    Text("Detailed Terms")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.top)
                    
                    dealerDetailedTerm(title: "Accuracy of Information",
                                       content: "Dealers are responsible for ensuring all provided information is accurate, current, and complete. This includes but is not limited to contact details, vehicle information, and pricing.")
                    
                    dealerDetailedTerm(title: "Content Guidelines",
                                       content: "All content must be appropriate for a general audience. Offensive, discriminatory, or misleading content is strictly prohibited and will be removed.")
                    
                    dealerDetailedTerm(title: "Fair Use Policy",
                                       content: "Dealers are expected to use the platform fairly. Excessive posting, spamming, or any form of platform manipulation is not allowed.")
                    
                    dealerDetailedTerm(title: "Compliance and Penalties",
                                       content: "Failure to comply with these terms may result in warnings, temporary suspension, or permanent removal from the platform, depending on the severity and frequency of violations.")
                    
                    dealerDetailedTerm(title: "Right to Remove Content",
                                       content: "We reserve the right to remove any content that violates these terms or that we deem inappropriate for our platform, without prior notice.")
                }
                .padding(.vertical)
            }
        }
    }
    
    private func sectionView(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 10)
    }

    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top) {
            Text("•")
            Text(text)
        }
    }

    private func dealerDetailedTerm(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(content)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    NavigationStack {
        TermsAndConditionsView()
    }
}
