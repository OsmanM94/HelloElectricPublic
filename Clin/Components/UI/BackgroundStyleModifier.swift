//
//  BackgroundStyleModifier.swift
//  Clin
//
//  Created by asia on 24/09/2024.
//

import SwiftUI

struct BackgroundStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.tabColour.opacity(0.1).gradient)
                .ignoresSafeArea()
            
            content
        }
    }
}

