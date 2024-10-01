//
//  CarListingView.swift
//  Clin
//
//  Created by asia on 23/06/2024.
//

import SwiftUI

struct ListingView: View {
    @State private var viewModel = ListingViewModel()
    @State private var shouldScrollToTop: Bool = false
    @State private var showScrollToTopTip: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                vehicleTypePicker
                content
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
            .navigationTitle("Listings")
            .toolbar {
                listFilterSection
                scrollToTopButton
            }
        }
        .task {
            if viewModel.listings.isEmpty {
                await viewModel.loadListings()
            }
        }
        .onShake {
            shouldScrollToTop.toggle()
        }
    }
    
    private var vehicleTypePicker: some View {
        Picker("Vehicle Type", selection: $viewModel.selectedVehicleType) {
            ForEach(VehicleType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(.segmented)
        .padding()
        .disabled(viewModel.viewState == .loading)
    }
    
    private var listFilterSection: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Picker("Quick Filter", selection: $viewModel.listingFilter) {
                    ForEach(ListingFilter.allCases, id: \.self) { filter in
                        Label(filter.rawValue, systemImage: viewModel.filterSystemImage(for: filter))
                            .tag(filter)
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                    Text("Sort")
                }
                .tint(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .clipShape(Capsule())
            }
            .disabled(viewModel.viewState == .loading)
        }
    }
    
    private var scrollToTopButton: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                shouldScrollToTop.toggle()
            } label: {
                Image(systemName: "iphone.radiowaves.left.and.right")
                    .tint(.primary)
            }
            .disabled(viewModel.viewState == .loading)
            .popoverTip(ScrollToTopTip(), arrowEdge: .bottom)
            .onAppear { showScrollToTopTip = true }
            .onDisappear { showScrollToTopTip = false }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .loading:
            Spacer()
            CustomProgressView(message: "")
            Spacer()
            
        case .loaded:
            ListingSubview(viewModel: viewModel, shouldScrollToTop: $shouldScrollToTop)
            
        case .empty:
            Spacer()
            emptyStateView
            Spacer()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 5) {
            Image(systemName: "car.2.fill")
                .font(.system(size: 50))
                .foregroundStyle(.gray)
            Text("No \(viewModel.selectedVehicleType.rawValue) available")
                .font(.headline)
            Text("Check back later for updates")
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
    }
}

fileprivate struct ListingSubview: View {
    @Bindable var viewModel: ListingViewModel
    @Binding var shouldScrollToTop: Bool
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                listContent
            }
            .navigationDestination(for: Listing.self) { listing in
                DetailView(item: listing, showFavourite: true)
            }
            .listStyle(.plain)
            .refreshable { }
            .onChange(of: shouldScrollToTop) { _, newValue in
                if newValue {
                    withAnimation {
                        proxy.scrollTo(viewModel.listings.first?.id, anchor: .top)
                    }
                    shouldScrollToTop = false
                }
            }
        }
    }
    
    private var listContent: some View {
        Group {
            ForEach(viewModel.listings, id: \.id) { item in
                listingRow(for: item)
            }
            .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
            if viewModel.hasMoreListings {
                loadingIndicator
            }
        }
    }
    
    private func listingRow(for item: Listing) -> some View {
        NavigationLink(value: item) {
            ListingRowView(listing: item, showFavourite: true)
                .id(item.id)
        }
        .task {
            if item == viewModel.listings.last {
                await viewModel.loadListings()
            }
        }
    }
    
    private var loadingIndicator: some View {
        ProgressView()
            .scaleEffect(1.2)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .id(UUID())
            .listRowSeparator(.hidden, edges: .all)
    }
}

#Preview("MockData") {
    let _ = PreviewsProvider.shared.container.listingService.register { MockListingService() }
    ListingView()
        .environment(FavouriteViewModel())
}
