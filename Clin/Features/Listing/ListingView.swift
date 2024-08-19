//
//  CarListingView.swift
//  Clin
//
//  Created by asia on 23/06/2024.
//

import SwiftUI
import Factory

struct ListingView: View {
    @StateObject var viewModel = ListingViewModel()
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

fileprivate struct ListingSubview: View {
    @StateObject var viewModel: ListingViewModel
    
    @Binding var isDoubleTap: Bool
    @Binding var selectedTab: Tab
    
    var body: some View {
        Button(action: { selectedTab = .second }) {
            TextFieldSearchView(disableTextInput: true, search: .constant(""), action: {})
                .padding([.top, .bottom])
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        
        ScrollViewReader { proxy in
            List {
                ForEach(viewModel.listings, id: \.id) { item in
                    NavigationLink(value: item) {
                        ListingCell(listing: item)
                    }
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                
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
            .navigationDestination(for: Listing.self, destination: { listing in
                ListingDetailView(listing: listing)
            })
            .listStyle(.plain)
            .refreshable { await viewModel.refreshListings() }
            .onChange(of: isDoubleTap) { _,  newValue in
                if newValue {
                    withAnimation {
                        proxy.scrollTo(viewModel.listings.first?.id)
                    }
                    isDoubleTap = false
                }
            }
        }
    }
}


#Preview("MockData") {
    let _ = PreviewsProvider.shared.container.listingService.register { MockListingService() }
    ListingView(isDoubleTap: .constant(false), selectedTab: .constant(.first))
        .environmentObject(FavouriteViewModel())
}



