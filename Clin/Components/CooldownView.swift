//
//  CooldownView.swift
//  Clin
//
//  Created by asia on 10/08/2024.
//

import SwiftUI

struct CooldownView: View {
    @State private var isAnimating: Bool = false
    var message: String
    var retryAction: () -> Void
    
    var body: some View {
        ContentUnavailableView {
            Label {
                Text(message)
                    .padding(.top, 50)
            } icon: {
                ProgressView()
                    .scaleEffect(2.0)
            }
        } description: {
            Text("")
        } actions: {
            Button {
                retryAction()
            } label: {
                Text("Ok")
                    .font(.title2)
            }

        }
        .onAppear {
            isAnimating = true
        }
        .onDisappear {
            isAnimating = false
        }
    }
}

#Preview {
    CooldownView(message: "Please wait 10 seconds before refreshing again.", retryAction: {})
}
