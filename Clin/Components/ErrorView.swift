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
    
    var body: some View {
        ContentUnavailableView {
            Label {
                Text(message)
                    .foregroundColor(.red)
            } icon: {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.red)
            }
        } description: {
            Text("")
        } actions: {
            Button {
                retryAction()
            } label: {
                Text("Retry")
                    .font(.title2)
            }

        }
    }
}

#Preview {
    ErrorView(message: "The selected image contains sensitive content.", retryAction: {})
}
