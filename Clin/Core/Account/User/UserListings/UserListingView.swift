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
                VStack(spacing: 0) {
                    switch viewModel.viewState {
                    case .empty:
                        EmptyContentView(message: "No active listings found", systemImage: "tray.fill")
                        
                    case .loaded:
                        UserListingSubview(viewModel: viewModel)
                        
                    case .error(let message):
                        ErrorView(message: message, retryAction: {
                            Task { await viewModel.fetchUserListings() }
                        })
                    }
                }
                .padding(.top)
                .navigationTitle("Active listings")
            }
        }
        .task { await viewModel.fetchUserListings() }
    }
}

#Preview {
    UserListingView()
}

fileprivate struct UserListingSubview: View {
    @State private var showingEditView = false
    @State private var selectedListing: Listing?
    @Bindable var viewModel: UserListingsViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.userActiveListings, id: \.id) { listing in
                UserListingCell(listing: listing)
                    .swipeActions(allowsFullSwipe: false) {
                        Button("Edit") {
                            selectedListing = listing
                            showingEditView = true
                        }
                        .tint(.yellow)
                    }
            }
            .alignmentGuide(.listRowSeparatorLeading) { _ in
                0
            }
        }
        .listStyle(.plain)
        .sheet(item: $selectedListing, onDismiss: {
        Task { await viewModel.fetchUserListings() } }) { listing in
                ListingFormEditView(listing: listing)
        }
    }
}


