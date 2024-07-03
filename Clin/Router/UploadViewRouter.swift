//
//  ContentView.swift
//  Clin
//
//  Created by asia on 22/06/2024.
//

import SwiftUI

struct UploadViewRouter: View {
    
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(NetworkMonitor.self) private var networkMonitor
    
    var body: some View {
        Group {
            if authViewModel.authenticationState == .authenticated {
                UploadListingView()
                    .overlay(
                        !networkMonitor.isConnected ? NetworkMonitorView().background(Color.white.opacity(0.8)) : nil
                    )
            } else {
                AuthenticationView()
                    .overlay(
                        !networkMonitor.isConnected ? NetworkMonitorView().background(Color.white.opacity(0.8)) : nil
                    )
            }
        }
    }
}

