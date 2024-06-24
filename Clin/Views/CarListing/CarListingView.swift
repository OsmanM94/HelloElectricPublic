//
//  CarListingView.swift
//  Clin
//
//  Created by asia on 23/06/2024.
//

import SwiftUI

struct CarListingView: View {
    
    @State private var viewModel = CarListingViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                VStack {
                    switch viewModel.state {
                    case .idle:
                        ContentUnavailableView {
                            Label("Connection issue", systemImage: "wifi.slash")
                        } description: {
                            Text("Check your internet connection")
                        } actions: {
                            Button("Refresh") {
                                Task { await viewModel.fetchListings() }
                            }
                        }
                        
                    case .loading:
                        ProgressView()
                            .scaleEffect(1.5)
                        
                    case .loaded:
                        List {
                            ForEach(viewModel.listings, id: \.id) { item in
                                Text(item.title)
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            Task {
                                        if let id = item.id {
                                            await viewModel.deleteListing(at: id)
                                                }
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .toolbar {
                            Button(action: { Task { await viewModel.createListing() } }) {
                                Text("Add Listing")
                            }
                        }
                        
                        TextField("Add listing", text: $viewModel.title)
                            .textFieldStyle(.roundedBorder)
                            .padding()
                        
                    case .error(let message):
                        Text(message)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Listings")
        }
        .task {
            await viewModel.fetchListings()
        }
    }
}

#Preview {
    CarListingView()
}
