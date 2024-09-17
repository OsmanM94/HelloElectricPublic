//
//  SupportCenterView.swift
//  Clin
//
//  Created by asia on 01/09/2024.
//

import SwiftUI

struct SupportCenterView: View {
    let phoneNumber = AppConstants.Contact.phoneNumber
    
    var body: some View {
        ScrollView(.vertical) {
            Spacer()
                .frame(height: 150)
            VStack(spacing: 20) {
                Text("Support Center")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("If you have any issues or questions, please contact us.")
                    .multilineTextAlignment(.center)
                    .padding()
                
                Link(destination: URL(string: "tel:\(phoneNumber)")!) {
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundStyle(.white)
                        Text("Call Support")
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .background(Color.green.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Text("Our support team is available 9AM - 17PM.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("Or")
                
                Text("helloe@myyahoo.com")
                    
            }
            .padding()
            .navigationTitle("Support")
            .navigationBarTitleDisplayMode(.inline)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    SupportCenterView()
}
