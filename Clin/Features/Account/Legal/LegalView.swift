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
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Got questions?")
                        .font(.headline)
                        .fontDesign(.rounded)
                   
                    Spacer()
                    
                    Image(systemName: "questionmark.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.tabColour)
                        .clipShape(Circle())
                }
            
                NavigationLink("Call support") {
                    SupportCenterView()
                }
                .padding(.top)
                .foregroundStyle(.tabColour)
            }
            .padding()
            .background(Color.lightGrayBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding()
            
            Spacer()
        }
    }
}

#Preview {
    LegalView()
}

fileprivate struct LegalItemView: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let imageName: String
    
    var body: some View {
        VStack {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .padding()
                .foregroundStyle(.tabColour)
                .background(Color.tabColour.opacity(0.1))
                .clipShape(Circle())
            
            Text(title)
                .font(.headline)
                .foregroundStyle(foregroundStyle)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(Color.lightGrayBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private var foregroundStyle: some ShapeStyle {
        if colorScheme == .dark {
            return .white
        } else {
            return .black
        }
    }
    
}


