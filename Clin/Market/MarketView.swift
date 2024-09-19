//
//  MarketPlaceView.swift
//  Clin
//
//  Created by asia on 10/07/2024.
//

import SwiftUI

struct MarketView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(AccountViewModel.self) private var accountViewModel
    
    @State private var networkMonitor = NetworkMonitor()
    @State private var selectedTab: Int = 0
    
    @State private var showFaceID: Bool = true
    
    var body: some View {
        VStack {
            if accountViewModel.faceIDisEnabled && showFaceID {
                FaceIDView(onAuthentication: { showFaceID = false })
            } else {
                tabViewContent
            }
        }
    }
    
    private var tabViewContent: some View {
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
                .withNetworkStatusBanner(networkMonitor)
            
            LazyView(CreateFormView(authViewModel: authViewModel))
                .tag(2)
                .tabItem {
                    Label("Sell", systemImage: "plus")
                }
                .withNetworkStatusBanner(networkMonitor)
            
            LazyView(HubView())
                .tag(3)
                .tabItem {
                    Label("Hub", systemImage: "rectangle.grid.2x2.fill")
                }
                .withNetworkStatusBanner(networkMonitor)
            
            LazyView(AccountView(authViewModel: authViewModel))
                .tag(4)
                .tabItem {
                    Label("Account", systemImage: "person.fill")
                }
                .withNetworkStatusBanner(networkMonitor)
        }
        .onChange(of: selectedTab) { _, newTab in
            let intensity: CGFloat
            switch newTab {
            case 0:
                intensity = 0.5
            case 1:
                intensity = 0.5
            case 2:
                intensity = 0.7
            case 3:
                intensity = 0.5
            case 4:
                intensity = 0.5
            default:
                intensity = 0.5
            }
            accountViewModel.navigationSensoryFeedback(intensity: intensity)
        }
    }
}

#Preview {
    let _ = PreviewsProvider.shared.container.listingService.register { MockListingService() }
    MarketView()
        .environment(AuthViewModel())
        .environment(FavouriteViewModel())
        .environment(AccountViewModel())
}
