//
//  CarListingView.swift
//  Clin
//
//  Created by asia on 23/06/2024.
//

import SwiftUI

struct ListingView: View {
    @State private var viewModel: ListingViewModel
    @Binding var isDoubleTap: Bool
    @Binding var selectedTab: Tab
        
    init(viewModel: @autoclosure @escaping () -> ListingViewModel,
         isDoubleTap: Binding<Bool>, selectedTab: Binding<Tab>) {
        self._viewModel = State(wrappedValue: viewModel())
        self._isDoubleTap = isDoubleTap
        self._selectedTab = selectedTab
    }
    
    var body: some View {
        NavigationStack {
            Group {
                VStack(spacing: 0) {
                    switch viewModel.viewState {
                    case .loading:
                        ListingViewPlaceholder(retryAction: {
                            await viewModel.fetchListings()
                        })
                        
                    case .loaded:
                        ListingSubview(viewModel: viewModel, isDoubleTap: $isDoubleTap, selectedTab: $selectedTab)
                    }
                }
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
    @Bindable var viewModel: ListingViewModel
    
    @Binding var isDoubleTap: Bool
    @Binding var selectedTab: Tab
    
    var body: some View {
        Button(action: { selectedTab = .second }) {
            SearchableView()
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
    ListingView(viewModel: ListingViewModel(listingService: MockListingService()), isDoubleTap: .constant(false), selectedTab: .constant(.first))
        .environmentObject(FavouriteViewModel(favouriteService: MockFavouriteService()))
}

#Preview("API") {
    ListingView(viewModel: ListingViewModel(listingService: ListingService()), isDoubleTap: .constant(false), selectedTab: .constant(.first))
        .environmentObject(FavouriteViewModel(favouriteService: FavouriteService()))
}
