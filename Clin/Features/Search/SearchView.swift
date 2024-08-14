//
//  SearchView.swift
//  Clin
//
//  Created by asia on 13/08/2024.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var isPresented: Bool = false
    
    var body: some View {
        NavigationStack {
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
            .searchable(text: $viewModel.searchText, isPresented: $isPresented, placement: .navigationBarDrawer(displayMode: .always))
            .onAppear {
                performAfterDelay(0.1, action: {
                    isPresented = true
                })
            }
            .toolbar {
                Button("", systemImage: "line.3.horizontal.decrease.circle", action: {
//                    viewModel.showFilterSheet.toggle()
                })
            }
//            .searchSuggestions {
//                ForEach(viewModel.searchSuggestions, id: \.self) { suggestion in
//                    Text(suggestion)
//                        .searchCompletion(suggestion)
//                }
//            }
        }
    }
}

#Preview {
    SearchView()
}
