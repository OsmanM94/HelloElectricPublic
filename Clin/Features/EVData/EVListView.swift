//
//  EVDataListView.swift
//  Clin
//
//  Created by asia on 13/09/2024.
//

import SwiftUI

struct EVListView: View {
    @State private var viewModel = EVDataViewModel()
    @FocusState private var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.viewState {
                case .loading:
                    CustomProgressView()
                    
                case .loaded:
                    searchBar
                    listContent
                    
                case .empty:
                    searchBar
                    emptyStateView
                    
                case .error(let message):
                    ErrorView(message: message, retryAction: {
                        viewModel.resetStateToLoaded()
                    })
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
            .navigationTitle("Database")
            .toolbar {
                topBarLeadingToolbarContent
                keyboardToolbarContent
            }
            //.onDisappear { viewModel.resetState() }
        }
        .task {
            if viewModel.evDatabase.isEmpty {
                await viewModel.loadEVDatabase()
            }
        }
    }
    
    private var searchBar: some View {
        SearchBarView(searchText: $viewModel.searchText) {
            await viewModel.searchItems()
        }
        .focused($isPresented)
    }
    
    private var listContent: some View {
        List {
            ForEach(viewModel.evDatabase, id: \.id) { ev in
                NavigationLink(destination: EVDetailsView(evData: ev)) {
                    EVRowView(ev: ev)
                        .id(ev.id)
                }
            }
            
            if viewModel.hasMoreListings && !viewModel.evDatabase.isEmpty {
                loadingIndicator
                    .task {
                        await viewModel.loadMoreEVDatabase()
                    }
            }
        }
        .listStyle(.plain)
    }
    
    private var topBarLeadingToolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Clear") {
                viewModel.clearSearch()
            }
            .disabled(viewModel.searchText.isEmpty)
        }
    }
    
    private var keyboardToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer(minLength: 0)
            Button { isPresented = false } label: { Text("Done") }
        }
    }
    
    private var loadingIndicator: some View {
        ProgressView()
            .scaleEffect(1.2)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .id(UUID())
            .listRowSeparator(.hidden, edges: .all)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 5) {
            Image(systemName: "car.2.fill")
                .font(.system(size: 50))
                .foregroundStyle(.gray)
            Text("No available data")
                .font(.headline)
            Text("Check back later for updates")
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    EVListView()
}



