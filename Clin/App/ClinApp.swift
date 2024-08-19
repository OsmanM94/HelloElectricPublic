//
//  ClinApp.swift
//  Clin
//
//  Created by asia on 22/06/2024.
//

import SwiftUI

@main
struct ClinApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var networkMonitor = NetworkMonitor()
    @State private var favouriteViewModel = FavouriteViewModel()
    
    var body: some Scene {
        WindowGroup {
            MarketView()
                .environmentObject(authViewModel)
                .environment(networkMonitor)
                .environmentObject(favouriteViewModel)
        }
    }
}
