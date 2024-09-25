//
//  ErrorView.swift
//  Clin
//
//  Created by asia on 25/07/2024.
//

import SwiftUI

struct ErrorView: View {
    let message: String
    let refreshMessage: String
    let retryAction: () async -> Void
    let systemImage: String
    var body: some View {
        VStack {
            ContentUnavailableView {
                Label(message, systemImage: systemImage)
            } description: {
                Text("")
            } actions: {
                Button {
                    Task { await retryAction() }
                } label: {
                    Text(refreshMessage)
                        .font(.headline)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
    }
}

#Preview("Light Mode") {
    ErrorView(message: "Unable to load EV listings at this time.", refreshMessage: "Try again", retryAction: {}, systemImage: "xmark.circle.fill")
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    ErrorView(message: "Unable to load EV listings at this time.", refreshMessage: "Try again", retryAction: {}, systemImage: "xmark.circle.fill")
        .preferredColorScheme(.dark)
}
