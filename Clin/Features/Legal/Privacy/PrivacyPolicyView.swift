//
//  PrivacyPolicyView.swift
//  Clin
//
//  Created by asia on 08/07/2024.
//

import SwiftUI

struct PrivacyPolicyView: View {
    let sections = [
        ("Introduction", "We are committed to protecting your personal information and your right to privacy."),
        ("Information Collection", "We collect only the email address associated with your Sign in with Apple account. We do not collect names, addresses, payment information, or any other personal data."),
        ("Use of Information", "We use your email address solely for the purpose of account authentication and to provide our services."),
        ("Sharing of Information", "We do not share your email address or any other information with third parties."),
        ("Data Deletion", "You have the right to delete your account and all associated data at any time through the account settings in our app."),
        ("Security", "We implement industry-standard security measures to protect your email address and any associated data."),
        ("Changes to this Privacy Policy", "We may update this privacy policy from time to time. We will notify you of any changes by posting the new privacy policy on this page."),
        ("Contact Us", "If you have any questions about this privacy policy, please contact us at \(AppConstants.Contact.supportEmail).")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
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
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    PrivacyPolicyView()
}
