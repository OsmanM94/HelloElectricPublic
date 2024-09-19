//
//  CustomProgressView.swift
//  Clin
//
//  Created by asia on 24/07/2024.
//

import SwiftUI

struct CustomProgressView: View {
    let message: String
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(.placeholder.opacity(0.3))
                    .frame(width: 60, height: 60)
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(width: 45, height: 45)
            }
            
            VStack {
                Text(message)
                    .padding(.top)
            }
        }
    }
}

#Preview {
    CustomProgressView(message: "Authenticating...")
}
