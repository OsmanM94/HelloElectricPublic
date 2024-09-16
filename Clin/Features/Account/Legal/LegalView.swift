//
//  LegalView.swift
//  Clin
//
//  Created by asia on 01/09/2024.
//

import SwiftUI

struct LegalView: View {
    let gridItems = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            LazyVGrid(columns: gridItems, spacing: 20) {
                NavigationLink(destination: LazyView(PrivacyPolicyView())) {
                    LegalItemView(title: "Privacy Policy", imageName: "lock.shield.fill")
                }
                NavigationLink(destination: LazyView(SafetyView())) {
                    LegalItemView(title: "Safety", imageName: "exclamationmark.shield.fill")
                }
                
                NavigationLink(destination: LazyView(TermsAndConditionsView())) {
                    LegalItemView(title: "Terms and Conditions", imageName: "doc.text.fill")
                }
                
                NavigationLink(destination: LazyView(DisclaimerView())) {
                    LegalItemView(title: "Disclaimer", imageName: "hand.raised.fill")
                }
            }
            .padding()
            .navigationTitle("Legal")
            .navigationBarTitleDisplayMode(.inline)
            
            Spacer()
        }
    }
}

#Preview {
    LegalView()
}

fileprivate struct LegalItemView: View {
    let title: String
    let imageName: String
    
    var body: some View {
        VStack {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .padding()
                .foregroundStyle(.green.gradient)
                .background(Color.green.opacity(0.1))
                .clipShape(Circle())
            
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}


