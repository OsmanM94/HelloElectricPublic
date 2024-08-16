//
//  SearchView.swift
//  Clin
//
//  Created by asia on 13/08/2024.
//

import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    @FocusState private var isPresented: Bool
    let systemImageName: String = "line.3.horizontal.decrease.circle"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TextFieldSearchView(disableTextInput: false, search: $viewModel.searchText, action: {
                    await viewModel.searchItems(searchText: viewModel.searchText)
                })
                .focused($isPresented)
                .onAppear {
                    performAfterDelay(0.1, action: { isPresented = true })
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer(minLength: 0)
                    Button { isPresented = false } label: { Text("Done") }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("", systemImage: systemImageName, action: {})
                }
            }
            
            VStack(spacing: 0) {
                switch viewModel.viewState {
                case .idle:
                    SearchSubview(viewModel: viewModel)
                    
                case .loading:
                    ListingsPlaceholder(showTextField: false, retryAction: {})
                    
                case .loaded:
                    if viewModel.filteredListings.isEmpty {
                        ContentUnavailableView.search
                    } else {
                        SearchSubview(viewModel: viewModel)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
        }
        .onAppear { viewModel.viewState = .idle
        }
    }
}

fileprivate struct SearchSubview: View {
    @Bindable var viewModel: SearchViewModel

    var body: some View {
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
    }
}



#Preview {
    SearchView()
}
