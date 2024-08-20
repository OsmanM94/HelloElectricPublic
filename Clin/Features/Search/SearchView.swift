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
            Group {
                VStack(spacing: 0) {
                    switch viewModel.viewState {
                    case .idle:
                        searchBar
                        searchListView
                    case .loading:
                        CustomProgressView()
                    case .loaded:
                        if viewModel.filteredListings.isEmpty {
                            searchBar
                            ContentUnavailableView.search
                        } else {
                            searchBar
                            searchListView
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer(minLength: 0)
                        Button { isPresented = false } label: { Text("Done") }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("", systemImage: systemImageName, action: {})
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Reset") { viewModel.resetState() }
                        .disabled(viewModel.searchText.isEmpty)
                    }
                }
            }
            .navigationTitle("Search")
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
    }
    
    var searchListView: some View {
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

