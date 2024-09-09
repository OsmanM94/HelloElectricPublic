//
//  ErrorView.swift
//  Clin
//
//  Created by asia on 25/07/2024.
//

import SwiftUI

struct ErrorView: View {
    var message: String
    var retryAction: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.gray)
            
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            Button(action: retryAction) {
                Text("Try Again")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(buttonColor)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
    }
    
    private var buttonColor: Color {
        colorScheme == .dark ? Color.green.opacity(0.7) : Color.green
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.black : Color.white
    }
}

#Preview("Light Mode") {
    ErrorView(message: "Unable to load EV listings at this time.", retryAction: {})
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    ErrorView(message: "Unable to load EV listings at this time.", retryAction: {})
        .preferredColorScheme(.dark)
}
