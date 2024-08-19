//
//  UserListingView.swift
//  Clin
//
//  Created by asia on 25/06/2024.
//
import SwiftUI

struct UserListingView: View {
    @StateObject private var viewModel = UserListingViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Group {
                    switch viewModel.viewState {
                    case .empty:
                        EmptyContentView(message: "No active listings found", systemImage: "tray.fill")
                    case .success:
                        UserListingSubview(viewModel: viewModel)
                        
                    case .error(let message):
                        ErrorView(message: message, retryAction: { Task {
                            await viewModel.fetchUserListings() } })
                    }
                }
                .navigationTitle("Active listings")
                .navigationBarTitleDisplayMode(.inline)
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
            .deleteAlert(
                isPresented:  $viewModel.showDeleteAlert,
                itemToDelete: $viewModel.listingToDelete
            ) { listing in
                Task {
                    await viewModel.deleteUserListing(listing)
                    await viewModel.fetchUserListings()
                }
            }
        }
        .task {
            if viewModel.userActiveListings.isEmpty {
                await viewModel.fetchUserListings()
            }
        }
    }
}

#Preview("MockData") {
    UserListingView()
}

fileprivate struct UserListingSubview: View {
    @StateObject var viewModel: UserListingViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.userActiveListings, id: \.id) { listing in
                UserListingCell(listing: listing)
                    .swipeActions(allowsFullSwipe: false) {
                        Button("Delete") {
                            viewModel.listingToDelete = listing
                            viewModel.showDeleteAlert.toggle()
                        }
                        .tint(.red)
                
                        Button("Edit") {
                            viewModel.selectedListing = listing
                            viewModel.showingEditView = true
                        }
                        .tint(.yellow)
                    }
            }
            .alignmentGuide(.listRowSeparatorLeading) { _ in
                0
            }
        }
        .refreshable { await viewModel.fetchUserListings() }
        .listStyle(.plain)
        .fullScreenCover(
            item: $viewModel.selectedListing,
            onDismiss: {
                Task {
                    await viewModel.fetchUserListings()
                }
            }) { listing in
                EditFormView(listing: listing)
        }
        .padding(.top)
    }
}

