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
    
    @State private var isActive: Bool = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isActive {
                    MarketView()
                        .environment(authViewModel)
                        .environment(networkMonitor)
                        .environment(favouriteViewModel)
                } else {
                    SplashView()
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut) {
                        self.isActive = true
                    }
                }
            }
        }
    }
}
