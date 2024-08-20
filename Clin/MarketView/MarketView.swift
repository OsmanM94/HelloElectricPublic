//
//  MarketPlaceView.swift
//  Clin
//
//  Created by asia on 10/07/2024.
//

import SwiftUI

struct MarketView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ListingView()
                .tag(0)
                .tabItem {
                    Label("Listings", systemImage: "bolt.car")
                }
            SearchView()
                .tag(1)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            CreateListingViewRouter()
                .tag(2)
                .tabItem {
                    Label("Sell", systemImage: "plus")
                }
            
            AccountViewRouter()
                .tag(3)
                .tabItem {
                    Label("Account", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    let _ = PreviewsProvider.shared.container.listingService.register { MockListingService() }
    MarketView()
        .environment(AuthViewModel())
        .environment(NetworkMonitor())
        .environment(FavouriteViewModel())
}
