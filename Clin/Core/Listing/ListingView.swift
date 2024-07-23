//
//  CarListingView.swift
//  Clin
//
//  Created by asia on 23/06/2024.
//

import SwiftUI

struct ListingView: View {
    
    @State private var viewModel = ListingViewModel()
    @State private var text: String = ""
    
    var body: some View {
        NavigationStack {
            Group {
                VStack {
                    switch viewModel.viewState {
                    case .loading:
                        Button(action: {}) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .frame(width: 45, height: 45)
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.roundedRectangle(radius: 15))
                        
                    case .loaded:
                        List {
                            ForEach(viewModel.listings, id: \.id) { item in
                                Text(item.make)
                            }
                        }
                        .searchable(text: $text, placement:
                                .navigationBarDrawer(displayMode: .always))
                        .refreshable {
                            await viewModel.fetchListings()
                        }
                        .toolbar {
                            Button("", systemImage: "line.3.horizontal.decrease.circle", action: {
                                viewModel.showFilterSheet.toggle()
                            })
                        }
                    }
                }
                .sheet(isPresented: $viewModel.showFilterSheet, content: {})
            }
            .navigationTitle("Listings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task { await viewModel.fetchListings() }
    }
}

#Preview {
    ListingView()
}


