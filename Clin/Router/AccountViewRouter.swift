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
    
    let imageManager: ImageManagerProtocol
    let prohibitedWordsService: ProhibitedWordsServiceProtocol
    let listingService: ListingServiceProtocol
    let httpDownloader: HTTPDataDownloaderProtocol
    
    init(imageManager: ImageManagerProtocol, prohibitedWordsService: ProhibitedWordsServiceProtocol, listingService: ListingServiceProtocol, httpDownloader: HTTPDataDownloaderProtocol) {
        self.imageManager = imageManager
        self.prohibitedWordsService = prohibitedWordsService
        self.listingService = listingService
        self.httpDownloader = httpDownloader
    }

    var body: some View {
        Group {
            if authViewModel.authenticationState == .authenticated {
                AccountView(
                    imageManager: imageManager,
                    prohibitedWordsService: prohibitedWordsService,
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

