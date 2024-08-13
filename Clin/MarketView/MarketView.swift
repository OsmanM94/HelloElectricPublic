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
            ListingView(viewModel: ListingViewModel(listingService: ListingService()), isDoubleTap: $viewModel.scrollFirstTabToTop)
                .tag(Tab.first)
                .tabItem {
                    Label("Listings", systemImage: "bolt.car")
                }
            
            CreateListingViewRouter()
                .tag(Tab.second)
                .tabItem {
                    Label("Sell", systemImage: "plus")
                }
            
            AccountViewRouter()
                .tag(Tab.third)
                .tabItem {
                    Label("Account", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    MarketView()
        .environment(AuthViewModel())
        .environment(NetworkMonitor())
        .environmentObject(FavouriteViewModel(favouriteService: MockFavouriteService()))
}

