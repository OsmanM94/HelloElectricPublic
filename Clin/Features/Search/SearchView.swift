//
//  SearchView.swift
//  Clin
//
//  Created by asia on 13/08/2024.
//

import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()
   
    var body: some View {
        NavigationStack {
            Group {
                VStack(spacing: 0) {
                    switch viewModel.viewState {
                    case .idle:
                        SearchSubview(viewModel: viewModel)
                    case .loading:
                        CustomProgressView()
                    case .loaded:
                        if viewModel.filteredListings.isEmpty {
                            SearchSubview(viewModel: viewModel)
                            ContentUnavailableView.search
                        } else {
                            SearchSubview(viewModel: viewModel)
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
            }
            .navigationTitle("Search")
        }
    }
}
struct SearchSubview: View {
    @Bindable var viewModel: SearchViewModel
    @FocusState private var isPresented: Bool
    @State private var showingFilterView = false
    let systemImageName: String = "line.3.horizontal.decrease.circle"
    
    var body: some View {
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
        .sheet(isPresented: $showingFilterView) {
            FilterView(viewModel: viewModel) {
                showingFilterView = false
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer(minLength: 0)
                Button { isPresented = false } label: { Text("Done") }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showingFilterView = true }) {
                    Image(systemName: systemImageName)
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button("Clear") {
                    viewModel.resetState()
                }
                .disabled(viewModel.searchText.isEmpty || !viewModel.filteredListings.isEmpty)
            }
        }
    }
}


#Preview {
    SearchView()
        .environment(FavouriteViewModel())
}

