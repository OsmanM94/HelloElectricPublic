//
//  CircularProgressBar.swift
//  Clin
//
//  Created by asia on 06/08/2024.
//

import SwiftUI

struct CircularProgressBar: View {
    var progress: Double
    var lineWidth: CGFloat = 30

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .opacity(0.3)
                .foregroundStyle(.green.gradient)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .foregroundStyle(.green.gradient)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
                .shadow(color: .gray, radius: 1)
            
            Text(String(format: "%.0f%%", min(progress, 1.0) * 100.0))
                .font(.title)
                .bold()
                .foregroundStyle(.green.gradient)
        }
        .frame(width: 250, height: 250)
        .padding()
    }
}

#Preview {
    CircularProgressBar(progress: 0.5)
}
