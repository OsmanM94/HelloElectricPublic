//
//  ListingDetailView.swift
//  Clin
//
//  Created by asia on 05/08/2024.
//

import SwiftUI

enum ListingFeatures: String, CaseIterable {
    case bodyType = "Body Type"
    case range = "Range"
    case publicChargingTime = "Public Charging (est.)"
    case homeChargingTime = "Home Charging (est.)"
    case powerBhp = "Power"
    case serviceHistory = "Service History"
    
    var iconName: String {
        switch self {
        case .bodyType: return "car"
        case .range: return "road.lanes"
        case .publicChargingTime: return "globe"
        case .homeChargingTime: return "house"
        case .powerBhp: return "bolt.fill"
        case .serviceHistory: return "wrench.and.screwdriver"
        }
    }
    
    var title: String { rawValue }
    
    func value(for listing: Listing) -> String {
        switch self {
        case .bodyType: return listing.bodyType
        case .range: return listing.range
        case .publicChargingTime: return listing.publicChargingTime
        case .homeChargingTime: return listing.homeChargingTime
        case .powerBhp: return listing.powerBhp
        case .serviceHistory: return listing.serviceHistory
        }
    }
}

struct ListingDetailView: View {
    // MARK: - Properties
    let listing: Listing
    let showFavourite: Bool
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    @State private var showSheet: Bool = false
    @State private var showSplash: Bool = true
    @State private var sellerProfileViewModel: PublicProfileViewModel
    
    // MARK: - Initialization
    init(listing: Listing, showFavourite: Bool) {
        self.listing = listing
        self.showFavourite = showFavourite
        _sellerProfileViewModel = State(wrappedValue: PublicProfileViewModel(sellerID: listing.userID))
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            if showSplash {
                splashView
            } else {
                mainContent
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Subviews
    private var splashView: some View {
        ListingDetailSplashView()
            .onAppear {
                performAfterDelay(1.5) {
                    withAnimation {
                        showSplash = false
                    }
                }
            }
    }
    
    private var mainContent: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 0) {
                imageCarousel
                
                VStack(alignment: .leading, spacing: 2) {
                    listingHeader
                    listingPrice
                    Divider()
                    overviewSection
                    featuresGrid
                    moreFeatures
                    descriptionSection
                    sellerSection
                }
                .padding()
                
                Spacer()
            }
        }
        .scrollIndicators(.never)
    }
    
    private var imageCarousel: some View {
        Group {
            if !listing.imagesURL.isEmpty {
                TabView {
                    ForEach(listing.imagesURL, id: \.self) { imageURL in
                        ImageLoader(url: imageURL, contentMode: .fill, targetSize: CGSize(width: 500, height: 500))
                            .clipped()
                            .onTapGesture { showSheet.toggle() }
                    }
                }
                .sheet(isPresented: $showSheet) {
                    SheetImages(listing: listing)
                }
                .tabViewStyle(.page)
                .containerRelativeFrame([.horizontal, .vertical]) { width, axis in
                    axis == .horizontal ? width : width * 0.50
                }
            } else {
                noImagesAvailable
            }
        }
    }
    
    private var noImagesAvailable: some View {
        Rectangle()
            .foregroundStyle(.gray.opacity(0.5))
            .frame(maxWidth: .infinity, minHeight: 600)
            .overlay {
                Text("No Images Available")
                    .foregroundStyle(.secondary)
                    .font(.headline)
            }
    }
    
    private var listingHeader: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(listing.condition)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(listing.make) \(listing.model) (\(listing.yearOfManufacture))")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .lineLimit(2, reservesSpace: false)
            }
            if showFavourite {
                Spacer()
                AddToFavouritesButton(listing: listing, iconSize: 22, width: 40, height: 40)
            }
        }
    }
    
    private var listingPrice: some View {
        Text(listing.price, format: .currency(code: Locale.current.currency?.identifier ?? "GBP").precision(.fractionLength(0)))
            .font(.title)
            .fontWeight(.bold)
            .padding(.top, 20)
    }
    
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Overview")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top)
            
            mileageInfo
        }
    }
    
    private var mileageInfo: some View {
        HStack(spacing: 15) {
            Image(systemName: "gauge.with.needle")
                .font(.system(size: 24))
                .foregroundStyle(.green)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Mileage")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(listing.mileage, format: .number) miles")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
        }
        .padding()
    }
    
    private var featuresGrid: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(ListingFeatures.allCases, id: \.self) { detail in
                featureItem(for: detail)
            }
        }
        .padding()
    }
    
    private func featureItem(for detail: ListingFeatures) -> some View {
        VStack {
            Image(systemName: detail.iconName)
                .font(.system(size: 24))
                .frame(height: 30)
            Text(detail.title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(detail.value(for: listing))
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private var moreFeatures: some View {
        DisclosureGroup("More features") {
            VStack(alignment: .leading, spacing: 15) {
                FeatureRow(title: "Number of Owners", value: listing.numberOfOwners)
                FeatureRow(title: "Battery Capacity", value: listing.batteryCapacity)
                FeatureRow(title: "Regenerative Braking", value: listing.regenBraking)
                FeatureRow(title: "Colour", value: listing.colour)
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private var descriptionSection: some View {
        DisclosureGroup("Description") {
            Text(listing.textDescription)
                .font(.body)
                .padding(.top, 10)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private var sellerSection: some View {
        DisclosureGroup("Seller") {
            VStack(alignment: .leading, spacing: 15) {
                Text("Details")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Location: \(listing.location)")
                    .foregroundStyle(.secondary)
                PublicProfileView(viewModel: sellerProfileViewModel)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(.top, 10)
            .overlay(alignment: .topTrailing) {
                ContactButtons()
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - SheetImages
fileprivate struct SheetImages: View {
    @Environment(\.dismiss) private var dismiss
    var listing: Listing
    
    var body: some View {
        NavigationStack {
            ZStack {
                if !listing.imagesURL.isEmpty {
                    imageTabView
                } else {
                    noImagesAvailable
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    dismissButton
                }
            }
        }
    }
    
    private var imageTabView: some View {
        TabView {
            ForEach(listing.imagesURL, id: \.self) { imageURL in
                ZoomImages {
                    ImageLoader(url: imageURL, contentMode: .fit, targetSize: CGSize(width: 500, height: 500))
                }
            }
        }
        .containerRelativeFrame([.horizontal,.vertical])
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
    
    private var noImagesAvailable: some View {
        Rectangle()
            .foregroundStyle(.gray.opacity(0.5))
            .overlay {
                Text("No Images Available")
                    .foregroundStyle(.secondary)
                    .font(.headline)
            }
    }
    
    private var dismissButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "x.circle.fill")
                .foregroundStyle(.gray)
                .font(.system(size: 25))
        }
    }
}

// MARK: - Preview
#Preview {
    ListingDetailView(listing: MockListingService.sampleData[0], showFavourite: true)
        .environment(FavouriteViewModel())
        .environment(PrivateProfileViewModel())
}


fileprivate struct FeatureRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

fileprivate struct ContactButtons: View {
    let phoneNumber = "07466861603"
    
    var body: some View {
        HStack(spacing: 5) {
            Link(destination: URL(string: "tel:\(phoneNumber)")!) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(.green.gradient)
                    Image(systemName: "phone.fill")
                        .foregroundStyle(.white)
                        .imageScale(.large)
                }
                .frame(width: 45, height: 45)
            }
            .padding(.top, 10)
            
            Link(destination: URL(string: "sms:\(phoneNumber)")!) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(.green.gradient)
                    Image(systemName: "bubble.fill")
                        .foregroundStyle(.white)
                        .imageScale(.large)
                }
                .frame(width: 45, height: 45)
            }
            .padding(.top, 10)
        }
    }
}
