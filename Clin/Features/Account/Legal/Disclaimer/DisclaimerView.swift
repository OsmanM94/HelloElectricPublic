//
//  CookieView.swift
//  Clin
//
//  Created by asia on 01/09/2024.
//

import SwiftUI

struct DisclaimerView: View {
    let sections = [
        ("General Disclaimer", [
            "This EV marketplace app ('HelloElectric') is a platform for connecting buyers and sellers of electric vehicles. We do not own, sell, or lease any vehicles listed on the App.",
            "All information provided by users, including vehicle details and pricing, is their sole responsibility. We do not verify or guarantee the accuracy of this information.",
            "We are not responsible for any losses, damages, or inconveniences resulting from using our App or engaging in transactions through it."
        ]),
        ("User Responsibility", [
            "Users are solely responsible for verifying the condition, ownership, and legal status of any vehicle before making a purchase.",
            "We strongly recommend that users conduct their own due diligence, including vehicle inspections and history checks, before completing any transaction.",
            "Users are responsible for ensuring compliance with all applicable laws and regulations related to buying, selling, and owning electric vehicles in their jurisdiction."
        ]),
        ("Transaction Risks", [
            "We do not guarantee the successful completion of any transaction initiated through our App.",
            "We are not responsible for any financial losses resulting from fraudulent activities, scams, or misrepresentations by users of our App.",
            "We do not mediate or resolve disputes between buyers and sellers. Users are encouraged to resolve conflicts directly or seek legal counsel if necessary."
        ]),
        ("Vehicle Condition and Performance", [
            "We do not guarantee the condition, quality, safety, or legality of any vehicle listed on our App.",
            "We are not responsible for any vehicle defects, malfunctions, or performance issues that may arise after a purchase.",
            "Users should thoroughly inspect and test drive any vehicle before purchase. We recommend having a qualified mechanic inspect the vehicle if possible."
        ]),
        ("Limitation of Liability", [
            "To the fullest extent permitted by law, we disclaim all warranties, express or implied, regarding the App and any transactions conducted through it.",
            "We shall not be liable for any direct, indirect, incidental, special, or consequential damages resulting from the use of our App or any transaction facilitated through it.",
            "Our total liability for any claim arising from the use of our App shall not exceed the amount paid by the user (if any) for using our services."
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
                            HStack(alignment: .center, spacing: 15) {
                                Text("•")
                                    .font(.headline)
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
        .navigationTitle("Disclaimer")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DisclaimerView()
}
