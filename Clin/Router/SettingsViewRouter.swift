//
//  SettingsViewRouter.swift
//  Clin
//
//  Created by asia on 03/07/2024.
//

import SwiftUI

struct SettingsViewRouter: View {
    
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(NetworkMonitor.self) private var networkMonitor
    
    var body: some View {
        Group {
            if authViewModel.authenticationState == .authenticated {
                SettingsView()
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

