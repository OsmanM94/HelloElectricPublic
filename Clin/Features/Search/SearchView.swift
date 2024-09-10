//
//  SearchView.swift
//  Clin
//
//  Created by asia on 13/08/2024.
//

import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    @State private var showingFilterView: Bool = false
    @FocusState private var isPresented: Bool
    let systemImageName: String = "line.3.horizontal.decrease.circle"
    
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
                    CustomProgressView()
                    
                case .noResults:
                    searchBar
                    ContentUnavailableView.search
                    listView
                    
                case .error(let message):
                    ErrorView(message: message, retryAction: {
                        viewModel.clearSearch()
                    })
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
            .navigationTitle("Search")
            .toolbar {
                keyboardToolbarContent
                topBarTrailingToolbarContent
                topBarLeadingToolbarContent
            }
            .sheet(isPresented: $showingFilterView) {
                FilterView(viewModel: viewModel) {
                    showingFilterView = false
                }
                .presentationDragIndicator(.visible)
            }
        }
    }
}

private extension SearchView {
    
    // MARK: - Search bar
    
    private var searchBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 5) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.gray)
                
                TextField("", text: $viewModel.searchText, prompt: Text("Search").foregroundStyle(.gray))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.search)
                    .padding(.vertical, 8)
                    .onSubmit { Task { await viewModel.searchItems() } }
            }
            .padding(.horizontal)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
            .focused($isPresented)
        }
        .padding(.bottom)
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
        .bold()
        .foregroundStyle(.secondary)
        .padding()
    }
   
    
    // MARK: - List View
    
     private var listView: some View {
        List {
            ForEach(viewModel.searchedItems, id: \.id) { item in
                NavigationLink(value: item) {
                    ListingCell(listing: item, showFavourite: true)
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
            Button(action: { showingFilterView = true }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: systemImageName)
                    
                    if viewModel.isFilterApplied {
                        Circle()
                            .foregroundStyle(.orange.gradient)
                            .frame(width: 11, height: 11)
                            .offset(x: 1, y: -1)
                    }
                }
            }
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
