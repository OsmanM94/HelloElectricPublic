//
//  ContentView.swift
//  Clin
//
//  Created by asia on 22/06/2024.
//

import SwiftUI

struct CreateListingViewRouter: View {
    
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(NetworkMonitor.self) private var networkMonitor
    
    let imageManager: ImageManager
    let prohibitedWordService: ProhibitedWordsService
    let listingService: ListingService
    let dvlaService: DvlaService
    let httpDataDownloader: HTTPDataDownloader
    
    init(imageManager: ImageManager, prohibitedWordService: ProhibitedWordsService, listingService: ListingService, dvlaService: DvlaService, httpDataDownloader: HTTPDataDownloader) {
        self.imageManager = imageManager
        self.prohibitedWordService = prohibitedWordService
        self.listingService = listingService
        self.dvlaService = dvlaService
        self.httpDataDownloader = httpDataDownloader
    }
    
    var body: some View {
        Group {
            if authViewModel.authenticationState == .authenticated {
                CreateFormView(viewModel: CreateFormViewModel(listingService: listingService, imageManager: imageManager, prohibitedWordsService: prohibitedWordService, httpDataDownloader: httpDataDownloader, dvlaService: dvlaService))
                    .overlay(
                        !networkMonitor.isConnected ? NetworkMonitorView().background(Color.white.opacity(0.8)) : nil
                    )
            } else {
                AuthenticationView()
                    .overlay(
                        !networkMonitor.isConnected ? NetworkMonitorView().background(Color.white.opacity(0.8)) : nil
                    )
            }
        }
    }
}

