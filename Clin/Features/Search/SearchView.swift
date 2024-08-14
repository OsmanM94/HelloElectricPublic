//
//  SearchView.swift
//  Clin
//
//  Created by asia on 13/08/2024.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @FocusState private var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchableView(search: $viewModel.searchText, disableTextInput: false)
                    .focused($isPresented)
                    .onAppear { performAfterDelay(0.1, action: {
                        isPresented = true
                    }) }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            
            VStack {
                switch viewModel.viewState {
                case .idle:
                    SearchSubview(viewModel: viewModel)
                    
                case .loading:
                    ListingViewPlaceholder(showTextField: false, retryAction: {})
                    
                case .loaded:
                    if viewModel.filteredListings.isEmpty {
                        ContentUnavailableView.search
                    } else {
                        SearchSubview(viewModel: viewModel)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
        }
        .onAppear { viewModel.viewState = .idle }
    }
}

fileprivate struct SearchSubview: View {
    @StateObject var viewModel: SearchViewModel
    let systemImageName: String = "line.3.horizontal.decrease.circle"
    
    var body: some View {
        List {
            ForEach(viewModel.filteredListings, id: \.id) { item in
                NavigationLink(value: item) {
                    ListingCell(listing: item)
                }
            }
            .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        }
        .navigationDestination(for: Listing.self, destination: { listing in
            ListingDetailView(listing: listing)
        })
        .listStyle(.plain)
        .transition(.opacity)
        .toolbar { Button("", systemImage: systemImageName, action: {})}
    }
}

#Preview {
    SearchView()
}
