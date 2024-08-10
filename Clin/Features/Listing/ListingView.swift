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
                    Text("\(viewModel.listings.count)")
                    switch viewModel.viewState {
                    case .loading:
                        CustomProgressView()
                        
                    case .loaded:
                        ListingSubview(viewModel: viewModel, isDoubleTap: $isDoubleTap)
                        
                    case .error(let message):
                        ErrorView(message: message, retryAction: {
                            Task { await viewModel.fetchListings() } })
                        
                    case .refreshCooldown(let message):
                        CooldownView(message: message, retryAction: {
                            viewModel.resetState()
                        })
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

#Preview("API") {
    ListingView(viewModel: ListingViewModel(listingService: ListingService()), isDoubleTap: .constant(false))
        .environmentObject(FavouriteViewModel(favouriteService: FavouriteService()))
}

#Preview("MockData") {
    ListingView(viewModel: ListingViewModel(listingService: MockListingService()), isDoubleTap: .constant(false))
        .environmentObject(FavouriteViewModel(favouriteService: FavouriteService()))
}

#Preview("Loading") {
    CustomProgressView()
}

#Preview("Refresh") {
    CooldownView(message: "Please wait 10 seconds before refreshing again. ", retryAction: {})
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
            .navigationDestination(for: Listing.self, destination: { item in
                ListingDetailView(listing: item)
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
            .onChange(of: isDoubleTap) {
                withAnimation {
                    proxy.scrollTo(viewModel.listings.first?.id)
                    print("DEBUG: Scrolling to top.")
                }
            }
        }
    }
}

