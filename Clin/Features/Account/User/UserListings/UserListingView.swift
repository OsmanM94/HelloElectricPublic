//
//  UserListingView.swift
//  Clin
//
//  Created by asia on 25/06/2024.
//
import SwiftUI

struct UserListingView: View {
    @State private var viewModel = UserListingViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.viewState {
                case .empty:
                    EmptyContentView(message: "No active listings found", systemImage: "tray.fill")
                case .success:
                    UserListingSubview(viewModel: viewModel)
                    
                case .error(let message):
                    ErrorView(message: message, retryAction: { Task {
                        await viewModel.loadUserListings() } })
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
            .navigationTitle("Active listings")
            .navigationBarTitleDisplayMode(.inline)
            .deleteAlert(
                isPresented:  $viewModel.showDeleteAlert,
                itemToDelete: $viewModel.listingToDelete
            ) { listing in
                Task {
                    await viewModel.deleteUserListing(listing)
                    await viewModel.loadUserListings()
                }
            }
        }
        .task {
            if viewModel.userActiveListings.isEmpty {
                await viewModel.loadUserListings()
            }
        }
    }
}

#Preview("MockData") {
    UserListingView()
}

fileprivate struct UserListingSubview: View {
    @Bindable var viewModel: UserListingViewModel
    
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
        .refreshable { await viewModel.loadUserListings() }
        .listStyle(.plain)
        .fullScreenCover(item: $viewModel.selectedListing, onDismiss: {
                Task {
                    await viewModel.loadUserListings()
                }
            }) { listing in
                EditFormView(listing: listing)
            }
            .padding(.top)
    }
}

