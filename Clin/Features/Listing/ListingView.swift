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
    
    init(viewModel: @autoclosure @escaping () -> ListingViewModel, isDoubleTap: Binding<Bool>) {
        self._viewModel = State(wrappedValue: viewModel())
        self._isDoubleTap = isDoubleTap
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
                        ListingSubview(viewModel: viewModel, isDoubleTap: $isDoubleTap)
                    }
                }
                .sheet(isPresented: $viewModel.showFilterSheet, content: {})
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
    @State private var text: String = ""
    @Binding var isDoubleTap: Bool
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(viewModel.listings, id: \.id) { item in
                    NavigationLink(value: item) {
                        ListingCell(listing: item)
                    }
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in
                    0
                }
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
            .searchable(text: $text, placement:
                    .navigationBarDrawer(displayMode: .always))
            .refreshable { await viewModel.refreshListings() }
            .toolbar {
                Button("", systemImage: "line.3.horizontal.decrease.circle", action: {
                    viewModel.showFilterSheet.toggle()
                })
            }
            .onChange(of: isDoubleTap) { _,  newValue in
                if newValue {
                    print("DEBUG: Scrolling to top is true")
                    withAnimation {
                        proxy.scrollTo(viewModel.listings.first?.id)
                        isDoubleTap = false
                        print("DEBUG: Scrolling to top is \(isDoubleTap)")
                    }
                }
            }
        }
    }
}

#Preview("MockData") {
    ListingView(viewModel: ListingViewModel(listingService: MockListingService()), isDoubleTap: .constant(false))
        .environmentObject(FavouriteViewModel(favouriteService: MockFavouriteService()))
}


#Preview("API") {
    ListingView(viewModel: ListingViewModel(listingService: ListingService()), isDoubleTap: .constant(false))
        .environmentObject(FavouriteViewModel(favouriteService: FavouriteService()))
}

