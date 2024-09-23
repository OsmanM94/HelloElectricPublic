//
//  ClinApp.swift
//  Clin
//
//  Created by asia on 22/06/2024.
//

import SwiftUI
import TipKit

@main
struct ClinApp: App {
    @State private var authViewModel = AuthViewModel()
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
                        .environment(favouriteViewModel)
                        .environment(accountViewModel)
                        .task {
                            try? Tips.configure([
                                .displayFrequency(.immediate),
                                .datastoreLocation(.applicationDefault)
                            ])
                        }
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
