//
//  CircularProgressBar.swift
//  Clin
//
//  Created by asia on 06/08/2024.
//
//
import SwiftUI

struct CircularProgressBar: View {
    var progress: Double
    var lineWidth: CGFloat = 30
    var size: CGFloat = 250
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .opacity(0.3)
                .foregroundStyle(backgroundGradient)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .foregroundStyle(foregroundGradient)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.easeInOut(duration: 1.0), value: progress)
            
            VStack(spacing: 5) {
                Text(String(format: "%.0f%%", min(progress, 1.0) * 100.0))
                    .font(.system(size: size * 0.2, weight: .bold, design: .rounded))
                
                Text("Complete")
                    .font(.system(size: size * 0.08, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .padding()
        .overlay(
            Circle()
                .stroke(Color.secondary.opacity(0.1), lineWidth: 4)
        )
        .shadow(color: shadowColor, radius: 10, x: 0, y: 5)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [.tabColour.opacity(0.3), .blue.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    private var foregroundGradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [.tabColour, .white]), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    private var textGradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [.tabColour, .blue]), startPoint: .leading, endPoint: .trailing)
    }
    
    private var shadowColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.2)
    }
}

struct CircularProgressBarPreview: View {
    @State private var progress: Double = 0.0
    
    var body: some View {
        CircularProgressBar(progress: progress)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    progress = 1.0
                }
            }
    }
}

#Preview("Light Mode") {
    CircularProgressBarPreview()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    CircularProgressBarPreview()
        .preferredColorScheme(.dark)
}
