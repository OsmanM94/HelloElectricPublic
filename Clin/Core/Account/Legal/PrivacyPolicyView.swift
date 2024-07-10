//
//  PrivacyPolicyView.swift
//  Clin
//
//  Created by asia on 08/07/2024.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .padding(.bottom)
                
                Text("""
                        1. Introduction
                        We are committed to protecting your personal information and your right to privacy.
                        
                        2. Information Collection
                        We collect personal information that you provide to us, such as name, address, contact information, and payment information.
                        
                        3. Use of Information
                        We use the information we collect to provide, maintain, and improve our services.
                        
                        4. Sharing of Information
                        We do not share your personal information with third parties without your consent, except as necessary to provide our services or comply with the law.
                        
                        5. Security
                        We implement security measures to protect your personal information.
                        
                        6. Changes to this Privacy Policy
                        We may update this privacy policy from time to time.
                        
                        7. Contact Us
                        If you have any questions about this privacy policy, please contact us at support@evmarketplace.com.
                        """)
                .padding(.bottom)
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    PrivacyPolicyView()
}
