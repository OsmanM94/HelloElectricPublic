//
//  CarListingView.swift
//  Clin
//
//  Created by asia on 23/06/2024.
//

import SwiftUI
import Factory

struct ListingView: View {
    @State private var viewModel = ListingViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                VStack {
                    switch viewModel.viewState {
                    case .loading:
                        ListingsPlaceholder(retryAction: {
                            await viewModel.fetchListings()
                        })
                        
                    case .loaded:
                        ListingSubview(viewModel: viewModel)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
                .navigationTitle("Listings")
            }
        }
        .task {
            if viewModel.listings.isEmpty {
                await viewModel.fetchListings()
            }
        }
    }
}

fileprivate struct ListingSubview: View {
    @Bindable var viewModel: ListingViewModel
    @State private var shouldScrollToTop: Bool = false
  
    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(viewModel.listings, id: \.id) { item in
                    NavigationLink(value: item) {
                        ListingCell(listing: item)
                            .id(item.id)
                    }
                    .task {
                        if item == viewModel.listings.last {
                            await viewModel.fetchListings()
                        }
                    }
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                
                if viewModel.hasMoreListings {
                    ProgressView()
                        .scaleEffect(1.0)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                }
            }
            .navigationDestination(for: Listing.self, destination: { listing in
                ListingDetailView(listing: listing)
            })
            .listStyle(.plain)
            .refreshable { await viewModel.refreshListings() }
            .onChange(of: shouldScrollToTop) { _, newValue in
                if newValue {
                    withAnimation {
                        proxy.scrollTo(viewModel.listings.first?.id, anchor: .top)
                    }
                    shouldScrollToTop = false
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        shouldScrollToTop.toggle()
                    } label: {
                        Image(systemName: "arrow.up.circle")
                    }
                    .disabled(viewModel.listings.count <= 10)
                }
            }
        }
    }
}

#Preview("MockData") {
    let _ = PreviewsProvider.shared.container.listingService.register { MockListingService() }
    ListingView()
        .environment(FavouriteViewModel())
}


