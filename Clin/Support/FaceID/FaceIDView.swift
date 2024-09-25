//
//  FaceIDView.swift
//  Clin
//
//  Created by asia on 19/09/2024.
//

import SwiftUI

struct FaceIDView: View {
    @Environment(AccountViewModel.self) private var accountViewModel
    
    @State private var faceID = FaceID()
    var onAuthentication: () -> Void
    
    var body: some View {
        VStack {
            switch faceID.viewState {
            case .idle:
                idleView
                
            case .loading:
                CustomProgressView(message: "Authenticating...")
                
            case .authenticated:
                Color.clear.onAppear {
                    onAuthentication()
                }
                
            case .error(let message):
                ErrorView(message: message,
                          refreshMessage: "Try again",
                          retryAction: {
                    Task { await faceID.authenticate() } }, systemImage: "xmark.circle.fill")
            }
        }
        .animation(.easeInOut(duration: 0.3), value: faceID.viewState)
        .task { await faceID.authenticate() }
    }
    
    private var idleView: some View {
        VStack(spacing: 50) {
            Image(systemName: "faceid")
                .font(.system(size: 50))
                .accessibilityLabel("Face ID icon")
        }
    }
}

#Preview {
    FaceIDView(onAuthentication: {})
        .environment(AccountViewModel())
}
