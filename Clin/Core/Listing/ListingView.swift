//
//  CarListingView.swift
//  Clin
//
//  Created by asia on 23/06/2024.
//

import SwiftUI

struct ListingView: View {
    
    @State private var viewModel: ListingViewModel
    
    init(viewModel: @autoclosure @escaping () -> ListingViewModel) {
        self._viewModel = State(wrappedValue: viewModel())
    }
    
    var body: some View {
        NavigationStack {
            Group {
                VStack(spacing: 0) {
                    switch viewModel.viewState {
                    case .loading:
                        CustomProgressView()
                        
                    case .loaded:
                        ListingSubview(viewModel: viewModel)
                        
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
        .task { await viewModel.fetchListings() }
    }
}

#Preview("API") {
    ListingView(viewModel: ListingViewModel(listingService: ListingService()))
        .environmentObject(FavouriteViewModel())
}

#Preview("MockData") {
    ListingView(viewModel: ListingViewModel(listingService: MockListingService()))
        .environmentObject(FavouriteViewModel())
}

#Preview("Loading") {
    CustomProgressView()
}


fileprivate struct ListingSubview: View {
    @Bindable var viewModel: ListingViewModel
    @State private var text: String = ""
    
    var body: some View {
        List {
            ForEach(viewModel.listings, id: \.id) { item in
                ListingCell(listing: item)
            }
            .alignmentGuide(.listRowSeparatorLeading) { _ in
                0
            }
        }
        .listStyle(.plain)
        .searchable(text: $text, placement:
                .navigationBarDrawer(displayMode: .always))
        .refreshable { await viewModel.fetchListings() }
        .toolbar {
            Button("", systemImage: "line.3.horizontal.decrease.circle", action: {
                viewModel.showFilterSheet.toggle()
            })
        }
    }
}

