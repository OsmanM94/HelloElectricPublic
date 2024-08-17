//
//  MarketPlaceView.swift
//  Clin
//
//  Created by asia on 10/07/2024.
//

import SwiftUI

struct MarketView: View {
    @StateObject private var viewModel: MarketViewModel
    
    let listingService: ListingService
    let imageManager: ImageManager
    let prohibitedWordService: ProhibitedWordsService
    let httpDataDownloader: HTTPDataDownloader
    let dvlaService: DvlaService
   
    init(viewModel: @autoclosure @escaping () -> MarketViewModel , listingService: ListingService, imageManager: ImageManager, prohibitedWordService: ProhibitedWordsService, httpDataDownloader: HTTPDataDownloader, dvlaService: DvlaService) {
        self._viewModel = StateObject(wrappedValue: viewModel())
        self.listingService = listingService
        self.imageManager = imageManager
        self.prohibitedWordService = prohibitedWordService
        self.httpDataDownloader = httpDataDownloader
        self.dvlaService = dvlaService
    }
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            ListingView(
                viewModel: ListingViewModel(listingService: listingService),
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
            
            CreateListingViewRouter(
                imageManager: imageManager,
                prohibitedWordService: prohibitedWordService,
                listingService: listingService,
                dvlaService: dvlaService,
                httpDataDownloader: httpDataDownloader)
                .tag(Tab.third)
                .tabItem {
                    Label("Sell", systemImage: "plus")
                }
            
            AccountViewRouter(
                imageManager: imageManager,
                prohibitedWordService: prohibitedWordService,
                listingService: listingService,
                httpDownloader: httpDataDownloader)
                .tag(Tab.fourth)
                .tabItem {
                    Label("Account", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    MarketView(
        viewModel: MarketViewModel(),
        listingService: ListingService(databaseService: DatabaseService()),
        imageManager: ImageManager(),
        prohibitedWordService: ProhibitedWordsService(),
        httpDataDownloader: HTTPDataDownloader(), dvlaService: DvlaService(httpDownloader: HTTPDataDownloader()))
        .environment(AuthViewModel())
        .environment(NetworkMonitor())
        .environmentObject(FavouriteViewModel(favouriteService: MockFavouriteService()))
}



