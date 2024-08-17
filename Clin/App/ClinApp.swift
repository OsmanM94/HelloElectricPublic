//
//  ClinApp.swift
//  Clin
//
//  Created by asia on 22/06/2024.
//

import SwiftUI

@main
struct ClinApp: App {
    
    @State private var authViewModel = AuthViewModel()
    @State private var networkMonitor = NetworkMonitor()
    @State private var favouriteViewModel: FavouriteViewModel
    @State private var marketViewModel: MarketViewModel
    @State private var listingViewModel: ListingViewModel
    @State private var createFormViewModel: CreateFormViewModel
    
    let databaseService = DatabaseService()
    let imageManager = ImageManager()
    let prohibitedWordsService = ProhibitedWordsService()
    let httpDataDownloader = HTTPDataDownloader()
    let dvlaService: DvlaService
    let listingService: ListingService
    
    init() {
        self.dvlaService = DvlaService(httpDownloader: httpDataDownloader)
        self.listingService = ListingService(databaseService: databaseService)
        self._favouriteViewModel = State(wrappedValue: FavouriteViewModel(favouriteService: FavouriteService(databaseService: databaseService)))
        self._marketViewModel = State(wrappedValue: MarketViewModel())
        self._listingViewModel = State(wrappedValue: ListingViewModel(listingService: listingService))
        self._createFormViewModel = State(wrappedValue: CreateFormViewModel(listingService: listingService, imageManager: imageManager, prohibitedWordsService: prohibitedWordsService, httpDataDownloader: httpDataDownloader, dvlaService: dvlaService))
    }

    var body: some Scene {
        WindowGroup {
            MarketView(
                viewModel: marketViewModel,
                listingViewModel: listingViewModel,
                createFormViewModel: createFormViewModel,
                listingService: listingService,
                imageManager: imageManager,
                prohibitedWordsService: prohibitedWordsService,
                httpDataDownloader: httpDataDownloader,
                dvlaService: dvlaService
            )
            .environment(authViewModel)
            .environment(networkMonitor)
            .environmentObject(favouriteViewModel)
        }
    }
}
