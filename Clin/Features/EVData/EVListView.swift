//
//  EVDataListView.swift
//  Clin
//
//  Created by asia on 13/09/2024.
//

import SwiftUI

struct EVListView: View {
    @State private var viewModel = EVDataViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.viewState {
                case .loading:
                    CustomProgressView()
                    
                case .loaded:
                    listContent
                    
                case .empty:
                    emptyStateView
                    
                case .error(let message):
                    ErrorView(message: message, retryAction: {
                        viewModel.resetState()
                    })
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
            .navigationTitle("Database")
        }
        .task {
            if viewModel.evDatabase.isEmpty {
                await viewModel.loadEVDatabase()
            }
        }
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
    }
}

#Preview {
    EVListView()
}



