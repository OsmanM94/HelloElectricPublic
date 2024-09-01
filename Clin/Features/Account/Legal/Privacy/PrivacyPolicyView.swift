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
        ("Information Collection", "We collect personal information that you provide to us, such as name, address, contact information, and payment information."),
        ("Use of Information", "We use the information we collect to provide, maintain, and improve our services."),
        ("Sharing of Information", "We do not share your personal information with third parties without your consent, except as necessary to provide our services or comply with the law."),
        ("Security", "We implement security measures to protect your personal information."),
        ("Changes to this Privacy Policy", "We may update this privacy policy from time to time."),
        ("Contact Us", "If you have any questions about this privacy policy, please contact us at support@evmarketplace.com.")
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
