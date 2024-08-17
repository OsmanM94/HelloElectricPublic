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
    
    let imageManager: ImageManagerProtocol
    let prohibitedWordsService: ProhibitedWordsServiceProtocol
    let listingService: ListingServiceProtocol
    let dvlaService: DvlaServiceProtocol
    let httpDataDownloader: HTTPDataDownloaderProtocol
    let createFormViewModel: CreateFormViewModel
    
    init(imageManager: ImageManagerProtocol, prohibitedWordsService: ProhibitedWordsServiceProtocol, listingService: ListingServiceProtocol, dvlaService: DvlaServiceProtocol, httpDataDownloader: HTTPDataDownloaderProtocol, createFormViewModel: @autoclosure @escaping () -> CreateFormViewModel) {
        self.imageManager = imageManager
        self.prohibitedWordsService = prohibitedWordsService
        self.listingService = listingService
        self.dvlaService = dvlaService
        self.httpDataDownloader = httpDataDownloader
        self.createFormViewModel = createFormViewModel()
    }
    
    var body: some View {
        Group {
            if authViewModel.authenticationState == .authenticated {
                CreateFormView(viewModel: createFormViewModel)
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

