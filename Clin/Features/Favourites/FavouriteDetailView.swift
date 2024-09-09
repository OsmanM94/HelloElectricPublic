//
//  FavouriteDetailView.swift
//  Clin
//
//  Created by asia on 06/09/2024.
//

import SwiftUI

enum FavouriteFeatures: String, CaseIterable {
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
    
    func value(for favourite: Favourite) -> String {
        switch self {
        case .bodyType: return favourite.bodyType
        case .range: return favourite.range
        case .publicChargingTime: return favourite.publicChargingTime
        case .homeChargingTime: return favourite.homeChargingTime
        case .powerBhp: return favourite.powerBhp
        case .serviceHistory: return favourite.serviceHistory
        }
    }
}

// MARK: - Main View

struct FavouriteDetailView: View {
    // MARK: Properties
    let favourite: Favourite
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    @State private var showSheet: Bool = false
    @State private var showSplash: Bool = true
    @State private var sellerProfileViewModel: PublicProfileViewModel
    
    // MARK: Initialization
    init(favourite: Favourite) {
        self.favourite = favourite
        _sellerProfileViewModel = State(wrappedValue: PublicProfileViewModel(sellerID: favourite.userID))
    }
    
    // MARK: Body
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
    
    // MARK: Subviews
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
                    listingPriceAndPromotedBadge
                    Divider()
                    overviewSection
                    featuresGrid
                    moreFeatures
                    descriptionSection
                    sellerSection
                }
                .fontDesign(.rounded).bold()
                .padding()
                
                Spacer()
            }
        }
        .scrollIndicators(.never)
    }
    
    // MARK: Image Carousel
    private var imageCarousel: some View {
        Group {
            if !favourite.imagesURL.isEmpty {
                TabView {
                    ForEach(favourite.imagesURL, id: \.self) { imageURL in
                        ImageLoader(url: imageURL, contentMode: .fill, targetSize: CGSize(width: 500, height: 500))
                            .clipped()
                            .onTapGesture { showSheet.toggle() }
                    }
                }
                .sheet(isPresented: $showSheet) {
                    SheetImages(favourite: favourite)
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
            .frame(maxWidth: .infinity, minHeight: 500)
            .overlay {
                Text("No Images Available")
                    .foregroundStyle(.secondary)
                    .font(.headline)
            }
    }
    
    // MARK: Favourite Details
    private var listingHeader: some View {
        VStack(alignment: .leading) {
            Text(favourite.condition)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("\(favourite.make) \(favourite.model) (\(favourite.yearOfManufacture))")
                .font(.title3)
                .fontWeight(.semibold)
                .lineLimit(2, reservesSpace: false)
        }
    }
    
    private var listingPriceAndPromotedBadge: some View {
        HStack {
            Text(favourite.price, format: .currency(code: Locale.current.currency?.identifier ?? "GBP").precision(.fractionLength(0)))
                .font(.title)
            
            Spacer()
            
            Text("Promoted")
                .foregroundStyle(.yellow)
                .padding(10)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .opacity(favourite.isPromoted ? 1 : 0)
        }
        .fontDesign(.rounded).bold()
        .padding(.top, 20)
    }
    
    // MARK: Overview Section
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Overview")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top)
            
            mileageInfo
        }
        .fontDesign(.rounded)
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
                Text("\(favourite.mileage, format: .number) miles")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
        }
        .padding()
    }
    
    // MARK: Features
    private var featuresGrid: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(FavouriteFeatures.allCases, id: \.self) { detail in
                featureItem(for: detail)
            }
        }
        .padding()
    }
    
    private func featureItem(for detail: FavouriteFeatures) -> some View {
        VStack {
            Image(systemName: detail.iconName)
                .font(.system(size: 24))
                .frame(height: 30)
            Text(detail.title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(detail.value(for: favourite))
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
                FeatureRow(title: "Number of Owners", value: favourite.numberOfOwners)
                FeatureRow(title: "Battery Capacity", value: favourite.batteryCapacity)
                FeatureRow(title: "Regenerative Braking", value: favourite.regenBraking)
                FeatureRow(title: "Colour", value: favourite.colour)
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    // MARK: Description
    private var descriptionSection: some View {
        DisclosureGroup("Description") {
            Text(favourite.textDescription)
                .font(.body)
                .padding(.top, 10)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    // MARK: Seller Section
    private var sellerSection: some View {
        DisclosureGroup("Seller") {
            VStack(alignment: .leading, spacing: 15) {
                Text("Details")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Location: \(favourite.location)")
                    .foregroundStyle(.secondary)
                PublicProfileView(viewModel: sellerProfileViewModel)
            }
            
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(.top, 10)
            .overlay(alignment: .topTrailing) {
                ContactButtons(favourite: favourite)
            }
            .overlay(alignment: .bottomTrailing) {
                ReportButton(itemId: favourite.id ?? 0, itemType: "Listing", reportEmail: "HelloElectric@support.com", iconSize: 15)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Supporting Views

// MARK: SheetImages
fileprivate struct SheetImages: View {
    @Environment(\.dismiss) private var dismiss
    var favourite: Favourite
    
    var body: some View {
        NavigationStack {
            ZStack {
                if !favourite.imagesURL.isEmpty {
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
            ForEach(favourite.imagesURL, id: \.self) { imageURL in
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

// MARK: FeatureRow
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

// MARK: ContactButtons
fileprivate struct ContactButtons: View {
    var favourite: Favourite
    
    var body: some View {
        HStack(spacing: 5) {
            Link(destination: URL(string: "tel:\(favourite.phoneNumber)")!) {
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
            
            Link(destination: URL(string: "sms:\(favourite.phoneNumber)")!) {
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

// MARK: - Preview
#Preview {
    FavouriteDetailView(favourite: MockFavouriteService.sampleData[2])
        .environment(FavouriteViewModel())
}
