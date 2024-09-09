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
            LazyView(ListingView())
                .tag(0)
                .tabItem {
                    Label("Listings", systemImage: "bolt.car")
                }
            LazyView(SearchView())
                .tag(1)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            LazyView(CreateListingViewRouter())
                .tag(2)
                .tabItem {
                    Label("Sell", systemImage: "plus")
                }
            
            LazyView(HubView())
                .tag(3)
                .tabItem {
                    Label("Hub", systemImage: "rectangle.grid.2x2.fill")
                }
            
//            LazyView(AccountViewRouter())
            AccountViewRouter()
                .tag(4)
                .tabItem {
                    Label("Account", systemImage: "person.fill")
                }
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: selectedTab)
    }
}

#Preview {
    let _ = PreviewsProvider.shared.container.listingService.register { MockListingService() }
    MarketView()
        .environment(AuthViewModel())
        .environment(NetworkMonitor())
        .environment(FavouriteViewModel())
}
