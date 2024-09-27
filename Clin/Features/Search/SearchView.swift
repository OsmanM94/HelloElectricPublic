//
//  SearchView.swift
//  Clin
//
//  Created by asia on 13/08/2024.
//

import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    @State private var showFilterView: Bool = false
    
    @FocusState private var isPresented: Bool
    let systemImageName: String = "slider.horizontal.3"
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                switch viewModel.viewState {
                case .idle:
                    searchBar
                    searchSuggestions
                    listView
                    
                case .loaded:
                    searchBar
                    listView
                    
                case .loading:
                    CustomProgressView(message: "Searching...")
                    
                case .noResults:
                    searchBar
                    ContentUnavailableView.search
                    listView
                    
                case .error(let message):
                    ErrorView(message: message,
                              refreshMessage: "Try again",
                              retryAction: {
                        viewModel.clearSearch()
                    }, systemImage: "xmark.circle.fill")
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
            .navigationTitle("Search")
            .toolbar {
                keyboardToolbarContent
                topBarTrailingToolbarContent
                topBarLeadingToolbarContent
            }
            .sheet(isPresented: $showFilterView) {
                FilterView(viewModel: viewModel)
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(viewModel.isLoadingAppliedFilters)
            }
        }
    }
}

private extension SearchView {
    
    // MARK: - Search bar
    
    private var searchBar: some View {
        SearchBarView(searchText: $viewModel.searchText, onSubmit: {
            Task { await viewModel.searchItems() }
        })
        .focused($isPresented)
    }
    
    // MARK: - Search suggestions
    
    private var searchSuggestions: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(viewModel.predefinedSuggestions, id: \.self) { suggestion in
                Text("eg. \(suggestion)")
                    .onTapGesture {
                        viewModel.handleSuggestionTap(suggestion)
                    }
            }
        }
        .fontDesign(.rounded)
        .foregroundStyle(.secondary)
        .padding()
    }
   
    // MARK: - List View
    
     private var listView: some View {
        List {
            ForEach(viewModel.searchedItems, id: \.id) { item in
                NavigationLink(value: item) {
                    ListingRowView(listing: item, showFavourite: true)
                        .id(item.id)
                }
                .task {
                    if item == viewModel.searchedItems.last && !viewModel.isSearching  {
                        await viewModel.loadMoreIfNeeded()
                    }
                }
            }
            .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
            
            if viewModel.hasMoreListings && !viewModel.searchedItems.isEmpty {
                ProgressView()
                    .scaleEffect(1.2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .id(UUID())
                    .listRowSeparator(.hidden, edges: .all)
            }
        }
        .navigationDestination(for: Listing.self, destination: { listing in
            DetailView(item: listing, showFavourite: true)
        })
        .listStyle(.plain)
    }
    
    // MARK: - Toolbar
    
    private var keyboardToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer(minLength: 0)
            Button { isPresented = false } label: { Text("Done") }
        }
    }
    
    private var topBarTrailingToolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: { showFilterView = true }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: systemImageName)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                    
                    if viewModel.filters.isFilterApplied {
                        Circle()
                            .foregroundStyle(.blue.gradient)
                            .frame(width: 15, height: 15)
                            .offset(x: 1, y: -1)
                    }
                }
            }
            .disabled(viewModel.viewState == .loading)
        }
    }
    
    private var topBarLeadingToolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Clear") {
                viewModel.clearSearch()
            }
            .disabled(viewModel.searchText.isEmpty && viewModel.searchedItems.isEmpty)
        }
    }
}

#Preview {
    let _ = PreviewsProvider.shared.container.searchService.register { MockSearchService() }
    SearchView()
        .environment(FavouriteViewModel())
}
