//
//  TermsAndConditionsView.swift
//  Clin
//
//  Created by asia on 08/07/2024.
//

import SwiftUI

struct TermsAndConditionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Terms and Conditions")
                    .font(.largeTitle)
                    .padding(.bottom)
                
                Text("""
                        1. Introduction
                        Welcome to our EV marketplace application. By using our app, you agree to comply with and be bound by the following terms and conditions.
                        
                        2. Use of the App
                        You agree to use the app only for lawful purposes and in accordance with these terms.
                        
                        3. Listings
                        You are responsible for the accuracy of the information provided in your listings.
                        
                        4. Privacy
                        Your use of the app is also governed by our Privacy Policy.
                        
                        5. Changes to Terms
                        We reserve the right to modify these terms at any time.
                        
                        6. Contact Us
                        If you have any questions about these terms, please contact us at support@evmarketplace.com.
                        """)
                .padding(.bottom)
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
