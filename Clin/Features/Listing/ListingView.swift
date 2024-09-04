//
//  CarListingView.swift
//  Clin
//
//  Created by asia on 23/06/2024.
//

import SwiftUI

struct ListingView: View {
    @State private var viewModel = ListingViewModel()
    @State private var selectedVehicleType: VehicleType = .cars

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                vehicleTypePicker
                content
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.viewState)
            .navigationTitle("Listings")
        }
        .task {
            if viewModel.listings.isEmpty {
                await viewModel.loadListings(vehicleType: selectedVehicleType)
            }
        }
    }
    
    private var vehicleTypePicker: some View {
           Picker("Vehicle Type", selection: $selectedVehicleType) {
               ForEach(VehicleType.allCases, id: \.self) { type in
                   Text(type.rawValue).tag(type)
               }
           }
           .pickerStyle(.segmented)
           .padding()
           .onChange(of: selectedVehicleType) { _, newValue in
               Task {
                   await viewModel.loadListings(isRefresh: true, vehicleType: newValue)
               }
           }
       }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .loading:
            ListingsPlaceholder(retryAction: loadListings)
        case .loaded:
            ListingSubview(viewModel: viewModel)
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
            Text("No \(selectedVehicleType.rawValue) available")
                .font(.headline)
            Text("Check back later for updates")
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
    }

    private func loadListings() async {
        await viewModel.loadListings(vehicleType: selectedVehicleType)
    }
}

fileprivate struct ListingSubview: View {
    @Bindable var viewModel: ListingViewModel
    @State private var shouldScrollToTop: Bool = false
    @State private var selectedVehicleType: VehicleType = .cars
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                listContent
            }
            .navigationDestination(for: Listing.self) { listing in
                ListingDetailView(listing: listing, showFavourite: true)
            }
            .listStyle(.plain)
            .refreshable {
                await viewModel.refreshListings(vehicleType: selectedVehicleType)
            }
           
            .onChange(of: shouldScrollToTop, scrollToTopHandler(proxy: proxy))
            .toolbar { scrollToTopButton }
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
            ListingCell(listing: item, showFavourite: true)
                .id(item.id)
        }
        .task {
            if item == viewModel.listings.last {
                await viewModel.loadListings(vehicleType: selectedVehicleType)
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
    
    private func scrollToTopHandler(proxy: ScrollViewProxy) -> (Bool, Bool) -> Void {
        return { _, newValue in
            if newValue {
                withAnimation {
                    proxy.scrollTo(viewModel.listings.first?.id, anchor: .top)
                }
                shouldScrollToTop = false
            }
        }
    }
    
    private var scrollToTopButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                shouldScrollToTop.toggle()
            } label: {
                Image(systemName: "arrow.up.circle")
            }
            .disabled(viewModel.listings.count <= 20)
        }
    }
}

#Preview("MockData") {
    let _ = PreviewsProvider.shared.container.listingService.register { MockListingService() }
    ListingView()
        .environment(FavouriteViewModel())
}
