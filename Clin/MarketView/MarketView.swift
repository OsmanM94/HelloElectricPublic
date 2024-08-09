//
//  MarketPlaceView.swift
//  Clin
//
//  Created by asia on 10/07/2024.
//

import SwiftUI

struct MarketView: View {
    @State private var viewModel = MarketViewModel()
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab.onUpdate { newValue in
            viewModel.handleTabSelection(newValue)
        }) {
            ListingView(viewModel: ListingViewModel(listingService: ListingService()), isDoubleTap: $viewModel.isDoubleTap)
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
    MarketView()
        .environment(AuthViewModel())
        .environment(NetworkMonitor())
        .environmentObject(FavouriteViewModel(favouriteService: MockFavouriteService()))
}
