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
    }

    var body: some Scene {
        WindowGroup {
            MarketView(
                viewModel: MarketViewModel(),
                listingService: listingService,
                imageManager: imageManager,
                prohibitedWordService: prohibitedWordsService,
                httpDataDownloader: httpDataDownloader,
                dvlaService: dvlaService
            )
            .environment(authViewModel)
            .environment(networkMonitor)
            .environmentObject(favouriteViewModel)
        }
    }
}
