//
//  SettingsViewRouter.swift
//  Clin
//
//  Created by asia on 03/07/2024.
//

import SwiftUI

struct AccountViewRouter: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(NetworkMonitor.self) private var networkMonitor
   
    var body: some View {
        Group {
            if authViewModel.authenticationState == .authenticated {
                AccountView()
            } else {
                AuthenticationView()
            }
        }
        .overlay(alignment: .top) {
            if !networkMonitor.isConnected {
                networkStatusBanner
            }
        }
    }
    
    private var networkStatusBanner: some View {
        NetworkMonitorView()
            .frame(maxWidth: .infinity)
            .background(backgroundStyle)
            .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    private var backgroundStyle: some ShapeStyle {
        .thinMaterial
    }
}

#Preview {
    AccountViewRouter()
        .environment(AuthViewModel())
        .environment(NetworkMonitor())
}

