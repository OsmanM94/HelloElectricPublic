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
            VStack {
                switch viewModel.viewState {
                case .idle, .loaded:
                    searchBar
                    listView
                case .loading:
                    CustomProgressView()
                case .empty:
                    searchBar
                    ContentUnavailableView.search
                    listView
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
            }
        }
    }
    
    private var keyboardToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer(minLength: 0)
            Button { isPresented = false } label: { Text("Done") }
        }
    }
    
    private var topBarTrailingToolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: { showingFilterView = true }) {
                Image(systemName: systemImageName)
            }
        }
    }
    
    private var topBarLeadingToolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Clear") {
                viewModel.resetState()
            }
            .disabled(viewModel.searchText.isEmpty || !viewModel.filteredListings.isEmpty)
        }
    }
}

extension SearchView {
    var searchBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 5) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.gray)
                
                TextField("", text: $viewModel.searchText, prompt: Text("Search").foregroundStyle(.gray))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.search)
                    .padding(.vertical, 8)
                    .onSubmit {
                        Task { await viewModel.searchItems() }
                    }
            }
            .padding(.horizontal)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
            .focused($isPresented)
        }
        .padding(.bottom)
    }
    
    var listView: some View {
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
        .environment(FavouriteViewModel())
}

