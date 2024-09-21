//
//  UserListingView.swift
//  Clin
//
//  Created by asia on 25/06/2024.
//
import SwiftUI

struct UserListingView: View {
    @State private var viewModel = UserListingViewModel()
    @State private var isEditing: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                contentView
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
            .navigationTitle("Active listings")
            .navigationBarTitleDisplayMode(.inline)
            .showDeleteAlert(
                isPresented: $viewModel.showDeleteAlert,
                itemToDelete: $viewModel.listingToDelete, // listingToDelete
                message: "Are you sure you want to delete this listing?",
                deleteAction: deleteListingAction
            )
            .toolbar {
                Button(isEditing ? "Done" : "Edit") {
                    isEditing.toggle()
                }
            }
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
            ErrorView(message: "Empty", retryAction: { await viewModel.loadUserListings() }, systemImage: "tray.fill")
            
        case .loading:
            CustomProgressView(message: "Loading...")
            
        case .success:
            contentSubview
            
        case .error(let message):
            ErrorView(message: message, retryAction: {
                Task { loadListingsAction } }, systemImage: "xmark.circle.fill")
        }
    }
    
    private func deleteListingAction(_ listing: Listing) async {
        await viewModel.deleteUserListing(listing)
        await viewModel.loadUserListings()
    }
    
    private func loadListingsAction() async {
        await viewModel.loadUserListings()
    }
    
    private var contentSubview: some View {
        List {
            ForEach(viewModel.userActiveListings, id: \.id) { listing in
                LazyView(listingRow(for: listing))
            }
            .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        }
        .environment(\.editMode, .constant(isEditing ? .active : .inactive))
        .refreshable { await viewModel.loadUserListings() }
        .listStyle(.plain)
        .fullScreenCover(item: $viewModel.selectedListing, onDismiss: dismissEditView) { listing in
            EditFormView(listing: listing)
        }
        .padding(.top)
    }
    
    private func listingRow(for listing: Listing) -> some View {
        HStack {
            NavigationLink(destination: DetailView(item: listing, showFavourite: false)) {
                ListingRowView(listing: listing, showFavourite: false)
                    .id(listing.id)
            }
            
            if isEditing {
                VStack(alignment: .leading, spacing: 30) {
                    deleteButton(for: listing)
                        .foregroundStyle(.red)
                    editButton(for: listing)
                        .foregroundStyle(.yellow)
                }
                .buttonStyle(.plain)
            }
        }
        .swipeActions(allowsFullSwipe: false) {
            deleteButton(for: listing)
            editButton(for: listing)
        }
    }
    
    private func deleteButton(for listing: Listing) -> some View {
        Button(action: {
            viewModel.listingToDelete = listing // listingToDelete
            viewModel.showDeleteAlert.toggle()
        }) {
            Label("Delete", systemImage: "trash")
        }
        .tint(.red)
    }
    
    private func editButton(for listing: Listing) -> some View {
        Button(action: {
            viewModel.selectedListing = listing
            viewModel.showingEditView = true
        }) {
            Label("Edit", systemImage: "pencil")
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
