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
    let createFormViewModel: CreateFormViewModel
    
    init(viewModel: @autoclosure @escaping () -> MarketViewModel,
         listingViewModel: @autoclosure @escaping () -> ListingViewModel,
         createFormViewModel: @autoclosure @escaping () -> CreateFormViewModel,
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
        self.createFormViewModel = createFormViewModel()
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
            
            CreateListingViewRouter(createFormViewModel: createFormViewModel)
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
    let listingService = PreviewHelpers.makeMockListingService()
    let imageManager = PreviewHelpers.makeMockImageManager()
    let prohibitedWordService = PreviewHelpers.makeMockProhibitedWordsService()
    let httpDataDownloader = PreviewHelpers.makeMockHttpDataDownloader()
    let dvlaService = PreviewHelpers.makeMockDvlaService()
    let listingViewModel = PreviewHelpers.makePreviewListingViewModel()
    let createFormViewModel = PreviewHelpers.makePreviewCreateFormViewModel()
    
    return MarketView(
        viewModel: MarketViewModel(),
        listingViewModel: listingViewModel,
        createFormViewModel: createFormViewModel,
        listingService: listingService,
        imageManager: imageManager,
        prohibitedWordsService: prohibitedWordService,
        httpDataDownloader: httpDataDownloader,
        dvlaService: dvlaService
    )
    .environment(AuthViewModel())
    .environment(NetworkMonitor())
    .environmentObject(PreviewHelpers.makeMockFavouriteViewModel())
}


