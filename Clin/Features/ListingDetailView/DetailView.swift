//
//  DetailView.swift
//  Clin
//
//  Created by asia on 09/09/2024.
//

import SwiftUI
import MapKit

// MARK: - Protocols

protocol DetailItem {
    var id: Int? { get }
    var condition: String { get }
    var make: String { get }
    var model: String { get }
    var yearOfManufacture: String { get }
    var price: Double { get }
    var isPromoted: Bool { get }
    var mileage: Double { get }
    var imagesURL: [URL] { get }
    var bodyType: String { get }
    var range: String { get }
    var publicChargingTime: String { get }
    var homeChargingTime: String { get }
    var powerBhp: String { get }
    var serviceHistory: String { get }
    var numberOfOwners: String { get }
    var batteryCapacity: String { get }
    var regenBraking: String { get }
    var colour: String { get }
    var textDescription: String { get }
    var location: String { get }
    var phoneNumber: String { get }
    var userID: UUID { get }
    var latitude: Double? { get }
    var longitude: Double? { get }
}

// MARK: - Extensions

extension Listing: DetailItem {}
extension Favourite: DetailItem {}


// MARK: - Enums

enum DetailFeatures: String, CaseIterable {
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
    
    func value(for item: DetailItem) -> String {
        switch self {
        case .bodyType: return item.bodyType
        case .range: return item.range
        case .publicChargingTime: return item.publicChargingTime
        case .homeChargingTime: return item.homeChargingTime
        case .powerBhp: return item.powerBhp
        case .serviceHistory: return item.serviceHistory
        }
    }
}

// MARK: - Main View

struct DetailView<T: DetailItem>: View {
    // MARK: Properties
    let item: T
    let showFavourite: Bool
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    @State private var showSheetImages: Bool = false
    @State private var showLocationPopover: Bool = false
    @State private var isMapExpanded: Bool = false
    @State private var showSplash: Bool = true
    
    @State private var sellerProfileViewModel: ListingProfileViewModel
    @State private var sellerPublicListings: PublicUserListingsViewModel
    
    // MARK: Initialization
    init(item: T, showFavourite: Bool = false) {
        self.item = item
        self.showFavourite = showFavourite
        
        _sellerProfileViewModel = State(wrappedValue: ListingProfileViewModel(sellerID: item.userID))
        _sellerPublicListings = State(wrappedValue: PublicUserListingsViewModel(sellerID: item.userID))
    }
    
    // MARK: Body
    var body: some View {
        ScrollView {
            VStack {
                imageCarousel
                if showSplash {
                    splashView
                } else {
                    mainContent
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .scrollIndicators(.hidden)
    }
    
    // MARK: Subviews
    private var splashView: some View {
        DetailSplashView()
            .onAppear {
                performAfterDelay(1.5) {
                    withAnimation {
                        showSplash = false
                    }
                }
            }
    }
    
    private var mainContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                itemHeader
                itemPriceAndPromotedBadge
                Divider()
                overviewSection
                featuresGrid
                moreFeatures
                descriptionSection
                sellerSection
                disclaimerSection
            }
            .fontDesign(.rounded)
            .fontWeight(.semibold)
            .padding()
            
            Spacer()
        }
    }
    
    // MARK: Image Carousel
    private var imageCarousel: some View {
        Group {
            if !item.imagesURL.isEmpty {
                TabView {
                    ForEach(item.imagesURL, id: \.self) { imageURL in
                        ImageLoader(url: imageURL, contentMode: .fill, targetSize: CGSize(width: 500, height: 500))
                            .clipped()
                            .onTapGesture { showSheetImages.toggle() }
                    }
                }
                .sheet(isPresented: $showSheetImages) {
                    SheetImages(item: item)
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
    
    // MARK: Item Details
    private var itemHeader: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.condition)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(item.make) \(item.model) (\(item.yearOfManufacture))")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .lineLimit(2, reservesSpace: false)
            }
            
            Spacer()
            
            if showFavourite {
                AddToFavouritesButton(listing: item as! Listing, iconSize: 22, width: 40, height: 40)
            }
        }
    }
    
    private var itemPriceAndPromotedBadge: some View {
        HStack {
            Text(item.price, format: .currency(code: Locale.current.currency?.identifier ?? "GBP").precision(.fractionLength(0)))
                .font(.title)
            
            Spacer()
            
            Text("Promoted")
                .padding(10)
                .foregroundStyle(.tabColour.gradient)
                .background(Color.lightGrayBackground)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .opacity(item.isPromoted ? 1 : 0)
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
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Mileage")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(item.mileage, format: .number) miles")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
        }
        .padding()
    }
    
    // MARK: Features
    private var featuresGrid: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(DetailFeatures.allCases, id: \.self) { detail in
                featureItem(for: detail)
            }
        }
        .padding()
    }
    
    private func featureItem(for detail: DetailFeatures) -> some View {
        VStack {
            Image(systemName: detail.iconName)
                .font(.system(size: 24))
                .frame(height: 30)
            Text(detail.title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(detail.value(for: item))
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.lightGrayBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private var moreFeatures: some View {
        DisclosureGroup("More features") {
            VStack(alignment: .leading, spacing: 15) {
                FeatureRow(title: "Number of Owners", value: item.numberOfOwners)
                FeatureRow(title: "Battery Capacity", value: item.batteryCapacity)
                FeatureRow(title: "Regenerative Braking", value: item.regenBraking)
                FeatureRow(title: "Colour", value: item.colour)
            }
            .fontWeight(.regular)
            .padding(.top, 10)
        }
        .padding()
        .background(Color.lightGrayBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    // MARK: Description
    private var descriptionSection: some View {
        DisclosureGroup("Description") {
            Text(item.textDescription)
                .fontWeight(.regular)
                .padding(.top, 10)
        }
        .padding()
        .background(Color.lightGrayBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    // MARK: Seller Section
    private var sellerSection: some View {
        DisclosureGroup("Seller", isExpanded: $isMapExpanded) {
            VStack(alignment: .leading, spacing: 15) {
                Text("Details")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                locationAndPopoverSection
                
                ListingProfileView(viewModel: sellerProfileViewModel)
                
                sellerOtherListingsSection
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(.top)
            .overlay(alignment: .topTrailing) {
                ContactButtons(item: item)
            }
            .overlay(alignment: .bottomTrailing) {
                ReportButton(itemId: item.id ?? 0, itemType: "Listing", iconSize: 15)
            }
            
            if isMapExpanded {
                locationMapSection
                    .transition(.opacity)
            } else {
                EmptyView()
            }
        }
        .padding()
        .background(Color.lightGrayBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private var locationAndPopoverSection: some View {
        HStack {
            Text("Location: \(item.location)")
                .foregroundStyle(.secondary)
            
            Button(action: {
                showLocationPopover.toggle()
            }) {
                Image(systemName: "info.circle")
                    .foregroundStyle(.blue)
            }
            .popover(isPresented: $showLocationPopover, arrowEdge: .bottom) {
                LocationDisclaimerView()
                    .presentationCompactAdaptation(.popover)
            }
        }
    }
    
    private var sellerOtherListingsSection: some View {
        NavigationLink {
            LazyView(PublicUserListingsView(viewModel: sellerPublicListings))
        } label: {
            Text("See seller other listings")
        }
    }
    
    private var locationMapSection: some View {
        Section {
            if let latitude = item.latitude,
               let longitude = item.longitude {
                LocationMapView(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            } else {
                Text("Map not available")
                    .padding(.top)
            }
        }
    }
    
    private var disclaimerSection: some View {
        DisclosureGroup("Disclaimer") {
            ListingDisclaimerView()
        }
        .padding()
        .background(Color.lightGrayBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Supporting Views

fileprivate struct SheetImages<T: DetailItem>: View {
    @Environment(\.dismiss) private var dismiss
    var item: T
    
    var body: some View {
        NavigationStack {
            ZStack {
                if !item.imagesURL.isEmpty {
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
            ForEach(item.imagesURL, id: \.self) { imageURL in
                ZoomImages {
                    ImageLoader(url: imageURL, contentMode: .fit, targetSize: CGSize(width: 500, height: 500))
                }
            }
        }
        .tabViewStyle(.page)
        .containerRelativeFrame([.horizontal, .vertical]) 
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

fileprivate struct FeatureRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
    }
}

fileprivate struct ContactButtons<T: DetailItem>: View {
    var item: T
    
    var body: some View {
        HStack(spacing: 5) {
            Link(destination: URL(string: "tel:\(item.phoneNumber)")!) {
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
            
            Link(destination: URL(string: "sms:\(item.phoneNumber)")!) {
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
    DetailView(item: MockListingService.sampleData[0], showFavourite: true)
        .environment(FavouriteViewModel())
}

