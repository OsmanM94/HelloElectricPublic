//
//  TermsAndConditionsView.swift
//  Clin
//
//  Created by asia on 08/07/2024.
//

import SwiftUI

struct TermsAndConditionsView: View {
    let sections = [
        ("Introduction", "Welcome to our EV marketplace application. By using our app, you agree to comply with and be bound by the following terms and conditions."),
        ("Use of the App", "You agree to use the app only for lawful purposes and in accordance with these terms."),
        ("Listings", "You are responsible for the accuracy of the information provided in your listings."),
        ("Privacy", "Your use of the app is also governed by our Privacy Policy."),
        ("Changes to Terms", "We reserve the right to modify these terms at any time."),
        ("Contact Us", "If you have any questions about these terms, please contact us at support@evmarketplace.com.")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Terms and Conditions")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .padding(.bottom)
                
                ForEach(sections.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(index + 1). \(sections[index].0)")
                            .font(.headline)
                        
                        Text(sections[index].1)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 10)
                    
                    if index < sections.count - 1 {
                        Divider()
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Terms and Conditions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    TermsAndConditionsView()
}
