//
//  SettingsViewRouter.swift
//  Clin
//
//  Created by asia on 03/07/2024.
//

import SwiftUI

struct AccountViewRouter: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(NetworkMonitor.self) private var networkMonitor
    
    let imageManager: ImageManager
    let prohibitedWordService: ProhibitedWordsService
    let listingService: ListingService
    let httpDownloader: HTTPDataDownloader
    
    init(imageManager: ImageManager, prohibitedWordService: ProhibitedWordsService, listingService: ListingService, httpDownloader: HTTPDataDownloader) {
        self.imageManager = imageManager
        self.prohibitedWordService = prohibitedWordService
        self.listingService = listingService
        self.httpDownloader = httpDownloader
    }

    var body: some View {
        Group {
            if authViewModel.authenticationState == .authenticated {
                AccountView(
                    imageManager: imageManager,
                    prohibitedWordService: prohibitedWordService,
                    listingService: listingService,
                    httpDownloader: httpDownloader)
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

