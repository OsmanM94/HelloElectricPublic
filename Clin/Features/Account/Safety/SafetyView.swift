//
//  SafetyView.swift
//  Clin
//
//  Created by asia on 08/07/2024.
//

import SwiftUI

struct SafetyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("How to Buy an EV")
                    .font(.headline)
                
                Text("""
        1. Research: Understand different EV models and their features.
        2. Budget: Set your budget, including any additional costs.
        3. Check Listings: Browse the listings on our marketplace.
        4. Contact Seller: Reach out to the seller for more details or to arrange a test drive.
        5. Verify Details: Ensure the vehicle details match the listing.
        6. Negotiate Price: Discuss and agree on a fair price.
        7. Complete Transaction: Arrange payment and transfer ownership.
        """)
                
                Text("How to Sell an EV")
                    .font(.headline)
                
                Text("""
        1. Prepare Your Vehicle: Clean and service your EV.
        2. Gather Information: Have your vehicle details ready, including make, model, year, color, mileage, and EV-specific information.
        3. Create a Listing: Enter your car registration number to auto-fill details and complete the listing.
        4. Set a Price: Determine a competitive price based on market value.
        5. Respond to Inquiries: Communicate with potential buyers promptly.
        6. Arrange Viewings: Set up times for buyers to see and test drive your EV.
        7. Finalize Sale: Negotiate and complete the transaction, ensuring payment and ownership transfer are handled securely.
        """)
                
                Text("Scam Prevention Tips")
                    .font(.headline)
                
                Text("""
        1. Verify Identities: Ensure you know who you are dealing with by verifying their contact information.
        2. Avoid Upfront Payments: Never pay for a vehicle in advance. Use secure payment methods and avoid wire transfers.
        3. Meet in Person: Always meet the buyer or seller in person in a safe, public location.
        4. Inspect the Vehicle: Thoroughly inspect the vehicle and confirm the details before making any payments.
        5. Check Vehicle History: Check vehicle history for any outstanding finance or previous accidents.
        6. Use Secure Payment Methods: Use trusted payment methods that offer protection against fraud.
        7. Report Suspicious Activity: If something feels off, trust your instincts and report any suspicious behavior to the platform and relevant authorities.
        8. Use Written Agreements: Document all agreements in writing, including the sale price and any terms and conditions.
        """)
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
