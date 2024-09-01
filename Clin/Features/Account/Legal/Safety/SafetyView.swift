//
//  SafetyView.swift
//  Clin
//
//  Created by asia on 08/07/2024.
//

import SwiftUI

struct SafetyView: View {
    let sections = [
        ("How to Buy an EV", [
            "Research: Understand different EV models and their features.",
            "Budget: Set your budget, including any additional costs.",
            "Check Listings: Browse the listings on our marketplace.",
            "Contact Seller: Reach out to the seller for more details or to arrange a test drive.",
            "Verify Details: Ensure the vehicle details match the listing.",
            "Negotiate Price: Discuss and agree on a fair price.",
            "Complete Transaction: Arrange payment and transfer ownership."
        ]),
        ("How to Sell an EV", [
            "Prepare Your Vehicle: Clean and service your EV.",
            "Gather Information: Have your vehicle details ready, including make, model, year, color, mileage, and EV-specific information.",
            "Create a Listing: Enter your car registration number to auto-fill details and complete the listing.",
            "Set a Price: Determine a competitive price based on market value.",
            "Respond to Inquiries: Communicate with potential buyers promptly.",
            "Arrange Viewings: Set up times for buyers to see and test drive your EV.",
            "Finalize Sale: Negotiate and complete the transaction, ensuring payment and ownership transfer are handled securely."
        ]),
        ("Scam Prevention Tips", [
            "Verify Identities: Ensure you know who you are dealing with by verifying their contact information.",
            "Avoid Upfront Payments: Never pay for a vehicle in advance. Use secure payment methods and avoid wire transfers.",
            "Meet in Person: Always meet the buyer or seller in person in a safe, public location.",
            "Inspect the Vehicle: Thoroughly inspect the vehicle and confirm the details before making any payments.",
            "Check Vehicle History: Check vehicle history for any outstanding finance or previous accidents.",
            "Use Secure Payment Methods: Use trusted payment methods that offer protection against fraud.",
            "Report Suspicious Activity: If something feels off, trust your instincts and report any suspicious behavior to the platform and relevant authorities.",
            "Use Written Agreements: Document all agreements in writing, including the sale price and any terms and conditions."
        ])
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                ForEach(sections, id: \.0) { section in
                    VStack(alignment: .leading, spacing: 15) {
                        Text(section.0)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                        
                        ForEach(section.1.indices, id: \.self) { index in
                            HStack(alignment: .top, spacing: 15) {
                                Text("\(index + 1)")
                                    .font(.headline)
                                    .foregroundStyle(.green)
                                    .frame(width: 25, alignment: .leading)
                                
                                Text(section.1[index])
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding(.vertical)
                    
                    if section.0 != sections.last!.0 {
                        Divider()
                    }
                }
            }
            .padding()
        }
        .navigationTitle("How to Buy and Sell")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SafetyView()
}
