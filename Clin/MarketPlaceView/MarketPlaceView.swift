//
//  MarketPlaceView.swift
//  Clin
//
//  Created by asia on 10/07/2024.
//

import SwiftUI

struct MarketPlaceView: View {
    
    @State private var selectedTab: Int = 0
   
    var body: some View {
        TabView(selection: $selectedTab) {
            CarListingView()
                .tabItem {
                    Label("Listings", systemImage: "bolt.car")
                }
                .tag(0)
            
            CreateListingViewRouter()
                .tabItem {
                    Label("Sell", systemImage: "plus")
                }
                .tag(1)
            
            AccountViewRouter()
                .tabItem {
                    Label("Account", systemImage: "person.fill")
                }
                .tag(2)
        }
    }
}

#Preview {
    MarketPlaceView()
        .environment(AuthViewModel())
        .environment(NetworkMonitor())
}
