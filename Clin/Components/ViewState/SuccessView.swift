//
//  SuccessView.swift
//  Clin
//
//  Created by asia on 25/07/2024.
//

import SwiftUI

struct SuccessView: View {
    var message: String
    var doneAction: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(iconColor)
            
            Text(message)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
            
            Button(action: doneAction) {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .background(buttonColor)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var iconColor: Color {
        colorScheme == .dark ? Color.accent.opacity(0.8) : Color.accent
    }
    
    private var buttonColor: Color {
        colorScheme == .dark ? Color.accent.opacity(0.8) : Color.accent
    }
}

#Preview("Light Mode") {
    SuccessView(message: "Your EV listing has been successfully posted!", doneAction: {})
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    SuccessView(message: "Your EV listing has been successfully posted!", doneAction: {})
        .preferredColorScheme(.dark)
}
