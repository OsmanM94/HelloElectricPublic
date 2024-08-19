//
//  MarketPlaceView.swift
//  Clin
//
//  Created by asia on 10/07/2024.
//

import SwiftUI

struct MarketView: View {
    @StateObject private var viewModel = MarketViewModel()
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            ListingView(
                isDoubleTap: $viewModel.scrollFirstTabToTop,
                selectedTab: $viewModel.selectedTab)
                .tag(Tab.first)
                .tabItem {
                    Label("Listings", systemImage: "bolt.car")
                }
            
            SearchView()
                .tag(Tab.second)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            CreateListingViewRouter()
                .tag(Tab.third)
                .tabItem {
                    Label("Sell", systemImage: "plus")
                }
            
            AccountViewRouter()
                .tag(Tab.fourth)
                .tabItem {
                    Label("Account", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    MarketView()
        .environmentObject(AuthViewModel())
        .environment(NetworkMonitor())
        .environmentObject(FavouriteViewModel())
}


