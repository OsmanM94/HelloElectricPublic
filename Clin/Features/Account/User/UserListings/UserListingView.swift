//
//  UserListingView.swift
//  Clin
//
//  Created by asia on 25/06/2024.
//
import SwiftUI

struct UserListingView: View {
    @State private var viewModel: UserListingViewModel
        
    init(viewModel: @autoclosure @escaping () -> UserListingViewModel) {
        self._viewModel = State(wrappedValue: viewModel())
    }
    
    var body: some View {
        NavigationStack {
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
            .deleteAlert(
                isPresented: $viewModel.showDeleteAlert,
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

#Preview("API") {
    UserListingView(viewModel: UserListingViewModel(listingService: ListingService()))
}

#Preview("MockData") {
    UserListingView(viewModel: UserListingViewModel(listingService: MockListingService()))
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
        .refreshable { await viewModel.fetchUserListings() }
        .listStyle(.plain)
        .fullScreenCover(item: $viewModel.selectedListing, onDismiss: {
            Task { await viewModel.fetchUserListings() }
        }) { listing in
            EditFormView(listing: listing, viewModel: EditFormViewModel(listingService: ListingService(), imageManager: ImageManager(), prohibitedWordsService: ProhibitedWordsService()))
        }
        .padding(.top)
    }
}

