//
//  MarketPlaceView.swift
//  Clin
//
//  Created by asia on 10/07/2024.
//

import SwiftUI

struct MarketView: View {
    @StateObject private var viewModel: MarketViewModel
    
    let listingService: ListingServiceProtocol
    let imageManager: ImageManagerProtocol
    let prohibitedWordsService: ProhibitedWordsServiceProtocol
    let httpDataDownloader: HTTPDataDownloaderProtocol
    let dvlaService: DvlaServiceProtocol
    let listingViewModel: ListingViewModel
    
    init(viewModel: @autoclosure @escaping () -> MarketViewModel,
         listingViewModel: @autoclosure @escaping () -> ListingViewModel,
         listingService: ListingServiceProtocol,
         imageManager: ImageManagerProtocol,
         prohibitedWordsService: ProhibitedWordsServiceProtocol,
         httpDataDownloader: HTTPDataDownloaderProtocol,
         dvlaService: DvlaServiceProtocol) {
        self._viewModel = StateObject(wrappedValue: viewModel())
        self.listingViewModel = listingViewModel()
        self.listingService = listingService
        self.imageManager = imageManager
        self.prohibitedWordsService = prohibitedWordsService
        self.httpDataDownloader = httpDataDownloader
        self.dvlaService = dvlaService
    }
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            ListingView(
                viewModel: listingViewModel,
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
                prohibitedWordsService: prohibitedWordsService,
                listingService: listingService,
                dvlaService: dvlaService,
                httpDataDownloader: httpDataDownloader)
                .tag(Tab.third)
                .tabItem {
                    Label("Sell", systemImage: "plus")
                }
            
            AccountViewRouter(
                imageManager: imageManager,
                prohibitedWordsService: prohibitedWordsService,
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
        viewModel: MarketViewModel(), listingViewModel: ListingViewModel(listingService: MockListingService()),
        listingService: MockListingService(),
        imageManager: MockImageManager(isHeicSupported: true),
        prohibitedWordsService: MockProhibitedWordsService(
            prohibitedWords: [""]),
        httpDataDownloader: MockHTTPDataDownloader(),
        dvlaService: MockDvlaService()
    )
        .environment(AuthViewModel())
        .environment(NetworkMonitor())
        .environmentObject(FavouriteViewModel(favouriteService: MockFavouriteService()))
}



