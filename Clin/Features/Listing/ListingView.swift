//
//  CarListingView.swift
//  Clin
//
//  Created by asia on 23/06/2024.
//

import SwiftUI
import Factory

struct ListingView: View {
    @State var viewModel = ListingViewModel()
    @Binding var isDoubleTap: Bool
    @Binding var selectedTab: Tab
    
    var body: some View {
        NavigationStack {
            Group {
                VStack(spacing: 0) {
                    switch viewModel.viewState {
                    case .loading:
                        ListingsPlaceholder(showTextField: true, retryAction: {
                            await viewModel.fetchListings()
                        })
                        
                    case .loaded:
                        ListingSubview(viewModel: viewModel, isDoubleTap: $isDoubleTap, selectedTab: $selectedTab)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
            }
            .navigationTitle("Listings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            if viewModel.listings.isEmpty {
                await viewModel.fetchListings()
            }
        }
    }
}

struct ListingSubview: View {
    @Bindable var viewModel: ListingViewModel
    @Binding var isDoubleTap: Bool
    @Binding var selectedTab: Tab
    
    var body: some View {
        VStack {
            searchButton
            listingScrollView
        }
    }
}

// MARK: - Subviews
private extension ListingSubview {
    
    var searchButton: some View {
        Button(action: { selectedTab = .second }) {
            TextFieldSearchView(disableTextInput: true, search: .constant(""), action: {})
                .padding([.top, .bottom])
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    var listingScrollView: some View {
        ScrollViewReader { proxy in
            List {
                listingItems
                loadingIndicator
            }
            .navigationDestination(for: Listing.self) { listing in
                ListingDetailView(listing: listing)
            }
            .listStyle(.plain)
            .refreshable { await viewModel.refreshListings() }
            .onChange(of: isDoubleTap) { _, newValue in
                if newValue {
                    scrollToTop(proxy: proxy)
                    isDoubleTap = false
                }
            }
        }
    }
    
    var listingItems: some View {
        ForEach(viewModel.listings, id: \.id) { item in
            NavigationLink(value: item) {
                ListingCell(listing: item)
            }
        }
        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
    }
    
    var loadingIndicator: some View {
        Group {
            if viewModel.listings.last != nil && viewModel.hasMoreListings {
                ProgressView()
                    .scaleEffect(1.0)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
                    .task {
                        await viewModel.fetchListings()
                    }
            }
        }
    }
    
    func scrollToTop(proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo(viewModel.listings.first?.id)
        }
    }
}


#Preview("MockData") {
    let _ = PreviewsProvider.shared.container.listingService.register { MockListingService() }
    ListingView(isDoubleTap: .constant(false), selectedTab: .constant(.first))
        .environment(FavouriteViewModel())
}


