//
//  CarListingView.swift
//  Clin
//
//  Created by asia on 23/06/2024.
//

import SwiftUI

struct ListingView: View {
    
    @State private var viewModel = ListingViewModel()
    @State private var text: String = ""
    
    var body: some View {
        NavigationStack {
            Group {
                VStack {
                    switch viewModel.viewState {
                    case .loading:
                        CustomProgressView()
                    case .loaded:
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
                        .refreshable {
                            await viewModel.fetchListings()
                        }
                        .toolbar {
                            Button("", systemImage: "line.3.horizontal.decrease.circle", action: {
                                viewModel.showFilterSheet.toggle()
                            })
                        }
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
    ListingView()
        .environmentObject(FavouriteViewModel())
}

#Preview("SampleData") {
    Group {
        List(0 ..< 5) { _ in
            ForEach(Listing.sampleData, id: \.id) { listing in
                ListingCell(listing: listing)
                    .environmentObject(FavouriteViewModel())
            }
            .alignmentGuide(.listRowSeparatorLeading) { _ in
                0
            }
        }
        .listStyle(.plain)
    }
}

#Preview("Loading") {
    CustomProgressView()
}


