//
//  UserListingView.swift
//  Clin
//
//  Created by asia on 25/06/2024.
//

import SwiftUI

struct UserListingView: View {
    
    @State private var viewModel = UserListingsViewModel()
    
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
                            ForEach(viewModel.userActiveListings, id: \.id) { listing in
                                Text(listing.make)
                            }
                            .listRowSeparator(.hidden, edges: .all)
                        }
                        .listStyle(.plain)
                     
                    case .error(let message):
                        ContentUnavailableView {
                            Label {
                                Text(message)
                                    .foregroundColor(.red)
                            } icon: {
                                Image(systemName: "exclamationmark.circle")
                                    .foregroundColor(.red)
                            }
                        } actions: {
                            Button("Try again") {
                                Task {
                                    await viewModel.fetchUserListings()
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Active listings")
        }
        .task { await viewModel.fetchUserListings() }
    }
}

#Preview {
    UserListingView()
}
