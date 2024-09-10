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
                contentView
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
            .navigationTitle("Active listings")
            .navigationBarTitleDisplayMode(.inline)
            .deleteAlert(
                isPresented: $viewModel.showDeleteAlert,
                itemToDelete: $viewModel.listingToDelete,
                deleteAction: deleteListingAction
            )
        }
        .task {
            if viewModel.userActiveListings.isEmpty {
                await viewModel.loadUserListings()
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewState {
        case .empty:
            EmptyContentView(message: "Empty", systemImage: "tray.fill")
        case .success:
            UserListingSubview(viewModel: viewModel)
        case .error(let message):
            ErrorView(message: message, retryAction: {
                Task { loadListingsAction } })
        }
    }
    
    private func deleteListingAction(_ listing: Listing) async {
        await viewModel.deleteUserListing(listing)
        await viewModel.loadUserListings()
    }
    
    private func loadListingsAction() async {
        await viewModel.loadUserListings()
    }
}

fileprivate struct UserListingSubview: View {
    @Bindable var viewModel: UserListingViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.userActiveListings, id: \.id) { listing in
                listingRow(for: listing)
            }
            .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        }
        .refreshable { await viewModel.loadUserListings() }
        .listStyle(.plain)
        .fullScreenCover(item: $viewModel.selectedListing, onDismiss: dismissEditView) { listing in
            EditFormView(listing: listing)
        }
        .padding(.top)
    }
    
    private func listingRow(for listing: Listing) -> some View {
        NavigationLink(destination: DetailView(item: listing, showFavourite: false)) {
            ListingCell(listing: listing, showFavourite: false)
                .id(listing.id)
                .swipeActions(allowsFullSwipe: false) {
                    deleteButton(for: listing)
                    editButton(for: listing)
                }
        }
    }
    
    private func deleteButton(for listing: Listing) -> some View {
        Button("Delete") {
            viewModel.listingToDelete = listing
            viewModel.showDeleteAlert.toggle()
        }
        .tint(.red)
    }
    
    private func editButton(for listing: Listing) -> some View {
        Button("Edit") {
            viewModel.selectedListing = listing
            viewModel.showingEditView = true
        }
        .tint(.yellow)
    }
    
    private func dismissEditView() {
        Task {
            await viewModel.loadUserListings()
        }
    }
}

#Preview("MockData") {
    UserListingView()
        .environment(FavouriteViewModel())
}
