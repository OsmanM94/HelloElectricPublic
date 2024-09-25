//
//  UserListingView.swift
//  Clin
//
//  Created by asia on 25/06/2024.
//
import SwiftUI

struct PrivateUserListingsView: View {
    @State private var viewModel = PrivateUserListingsViewModel()
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
                message: "Are you sure you want to delete this listing?", title: "Delete confirmation",
                deleteAction: deleteListingAction
            )
            .toolbar {
                Button(isEditing ? "Done" : "Edit") {
                    isEditing.toggle()
                }
                .disabled(viewModel.listings.isEmpty)
            }
        }
        .task {
            if viewModel.listings.isEmpty {
                await viewModel.loadListings()
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewState {
        case .empty:
            ErrorView(message: "Empty", refreshMessage: "Refresh", retryAction: { await viewModel.loadListings() }, systemImage: "tray.fill")
            
        case .loading:
            CustomProgressView(message: "Loading...")
            
        case .refreshSuccess(let message):
            SuccessView(message: message) {
                Task { await viewModel.loadListings() }
            }
            
        case .success:
            contentSubview
            
        case .error(let message):
            ErrorView(message: message, refreshMessage: "Try again", retryAction: {
                Task { await viewModel.loadListings() } }, systemImage: "xmark.circle.fill")
        }
    }
    
    private var contentSubview: some View {
        List {
            ForEach(viewModel.listings, id: \.id) { listing in
                LazyView(listingRow(for: listing))
            }
            .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        }
        .environment(\.editMode, .constant(isEditing ? .active : .inactive))
        .refreshable { await viewModel.loadListings() }
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
                VStack(alignment: .leading, spacing: 25) {
                    deleteButton(for: listing)
                        .foregroundStyle(.red)
                    editButton(for: listing)
                        .foregroundStyle(.yellow)
                    refreshButton(for: listing)
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }
        }
        .swipeActions(allowsFullSwipe: false) {
            deleteButton(for: listing)
            editButton(for: listing)
            refreshButton(for: listing)
        }
    }
    
    private func deleteButton(for listing: Listing) -> some View {
        Button(action: {
            viewModel.listingToDelete = listing
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
    
    private func refreshButton(for listing: Listing) -> some View {
        Button(action: {
            Task {
                await viewModel.refreshListing(listing)
            }
        }) {
            Label("Refresh", systemImage: "arrow.clockwise")
        }
        .tint(.blue)
        .popoverTip(RefreshListingTip(), arrowEdge: .bottom)
    }
    
    private func refreshListingAction(_ listing: Listing) async {
        await viewModel.refreshListing(listing)
    }
    
    private func deleteListingAction(_ listing: Listing) async {
        await viewModel.deleteListing(listing)
        await viewModel.loadListings()
    }
    
    private func dismissEditView() {
        Task {
            await viewModel.loadListings()
        }
    }
}

#Preview("MockData") {
    PrivateUserListingsView()
        .environment(FavouriteViewModel())
}
