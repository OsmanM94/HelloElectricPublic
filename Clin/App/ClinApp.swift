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
    @StateObject private var favouriteViewModel = FavouriteViewModel()
   
    var body: some Scene {
        WindowGroup {
            MarketPlaceView()
                .environment(authViewModel)
                .environment(networkMonitor)
                .environmentObject(favouriteViewModel)
        }
    }
}
