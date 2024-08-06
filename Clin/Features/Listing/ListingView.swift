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
                        CustomProgressView()
                        
                    case .loaded:
                        ListingSubview(viewModel: viewModel, isDoubleTap: $isDoubleTap)
                        
                    case .error(let message):
                        ErrorView(message: message, retryAction: { Task {
                            await viewModel.fetchListings()
                        } })
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
        .environmentObject(FavouriteViewModel())
}

#Preview("MockData") {
    ListingView(viewModel: ListingViewModel(listingService: MockListingService()), isDoubleTap: .constant(false))
        .environmentObject(FavouriteViewModel())
}

#Preview("Loading") {
    CustomProgressView()
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
            }
            .navigationDestination(for: Listing.self, destination: { item in
                ListingDetailView(listing: item)
            })
            .listStyle(.plain)
            .searchable(text: $text, placement:
                    .navigationBarDrawer(displayMode: .always))
            .refreshable { await viewModel.fetchListings() }
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

