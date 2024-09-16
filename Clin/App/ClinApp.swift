//
//  ClinApp.swift
//  Clin
//
//  Created by asia on 22/06/2024.
//

import SwiftUI

@main
struct ClinApp: App {
    @State private var authViewModel = AuthViewModel()
    @State private var networkMonitor = NetworkMonitor()
    @State private var favouriteViewModel = FavouriteViewModel()
    @State private var accountViewModel = AccountViewModel()
    
    @State private var showSplashView: Bool = true
    
    var body: some Scene {
        WindowGroup {
            Group {
                if showSplashView {
                    SplashView()
                } else {
                    MarketView()
                        .environment(authViewModel)
                        .environment(networkMonitor)
                        .environment(favouriteViewModel)
                        .environment(accountViewModel)
                }
            }
            .onAppear {
                performAfterDelay(2.0) {
                    withAnimation(.easeInOut) { showSplashView = false }
                }
            }
        }
    }
}
