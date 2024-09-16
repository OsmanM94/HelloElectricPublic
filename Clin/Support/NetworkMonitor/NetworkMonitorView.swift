//
//  NetworkMonitorView.swift
//  Clin
//
//  Created by asia on 03/07/2024.
//

import SwiftUI

struct NetworkMonitorView: View {
    
    var body: some View {
        ContentUnavailableView {
            Label("Disconnected", systemImage: "antenna.radiowaves.left.and.right")
                .symbolEffect(.variableColor.cumulative.hideInactiveLayers.nonReversing,options: .repeating)
        } description: {
            Text("Check your internet connection.")
        } actions: {
            Button(action: {}) {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(width: 45, height: 45)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle(radius: 15))
        }
    }
}

#Preview {
    NetworkMonitorView()
}
