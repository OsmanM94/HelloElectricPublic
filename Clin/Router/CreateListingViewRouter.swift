//
//  ContentView.swift
//  Clin
//
//  Created by asia on 22/06/2024.
//

import SwiftUI

struct CreateListingViewRouter: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(NetworkMonitor.self) private var networkMonitor

    var body: some View {
        Group {
            if authViewModel.authenticationState == .authenticated {
                CreateFormView()
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
    CreateListingViewRouter()
        .environment(AuthViewModel())
        .environment(NetworkMonitor())
}
