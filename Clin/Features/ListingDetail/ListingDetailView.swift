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
    @Environment(ProfileViewModel.self) private var profileViewModel
    
    @State private var showSheet: Bool = false
    @State private var showSplash: Bool = false
    var listing: Listing
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    
    var body: some View {
        VStack {
            if showSplash {
                ListingDetailSplashView()
                    .onAppear {
                        performAfterDelay(1.5, action: {
                            withAnimation {
                                showSplash = false
                            }
                        })
                    }
            } else {
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 0) {
                        if !listing.imagesURL.isEmpty {
                            TabView {
                                ForEach(listing.imagesURL, id: \.self) { imageURL in
                                    ImageLoader(url: imageURL, contentMode: .fill, targetSize: CGSize(width: 500, height: 500))
                                        .clipped()
                                        .onTapGesture {
                                            showSheet.toggle()
                                        }
                                }
                            }
                            .sheet(isPresented: $showSheet, content: {
                                SheetImages(listing: listing)
                            })
                            .tabViewStyle(.page)
                            .containerRelativeFrame([.horizontal, .vertical]) { width, axis in
                                if axis == .horizontal {
                                    return width
                                } else {
                                    return width * 0.50
                                }
                            }
                        } else {
                            Rectangle()
                                .foregroundStyle(.gray.opacity(0.5))
                                .frame(maxWidth: .infinity, minHeight: 600)
                                .overlay {
                                    Text("No Images Available")
                                        .foregroundStyle(.secondary)
                                        .font(.headline)
                                }
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text("\(listing.condition)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                AddToFavouritesButton(listing: listing, iconSize: 22, width: 40, height: 40)
                            }
                            
                            Text("\(listing.make) \(listing.model) (\(listing.yearOfManufacture))")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .lineLimit(1, reservesSpace: true)
                            
                            Text(listing.price, format: .currency(code: Locale.current.currency?.identifier ?? "GBP").precision(.fractionLength(0)))
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.top, 20)
                            
                            Divider()
                            
                            Text("Overview")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.top)
                            
                            VStack(alignment: .leading, spacing: 20) {
                                // Mileage section
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
                            
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(ListingFeatures.allCases, id: \.self) { detail in
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
                            }
                            .padding()
                           
                            // More features section
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
                            
                            // Description section
                            DisclosureGroup("Description") {
                                Text(listing.textDescription)
                                    .font(.body)
                                    .padding(.top, 10)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Seller details")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text("Location: \(listing.location)")
                                    .foregroundStyle(.secondary)
                                
                                ProfileHeaderView(viewModel: profileViewModel)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                        }
                        .padding()
                       
                        Spacer()
                    }
                }
                .scrollIndicators(.never)
                .overlay(alignment: .bottomTrailing) {
                    ZStack {
                        Circle()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(.green.gradient)
                        Image(systemName: "phone.fill")
                            .foregroundStyle(.white)
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ListingDetailView(listing: MockListingService.sampleData[0])
        .environment(FavouriteViewModel())
        .environment(ProfileViewModel())
}

fileprivate struct SheetImages: View {
    @Environment(\.dismiss) private var dismiss
    var listing: Listing
    
    var body: some View {
        NavigationStack {
            ZStack {
                if !listing.imagesURL.isEmpty {
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
                } else {
                    Rectangle()
                        .foregroundStyle(.gray.opacity(0.5))
                        .overlay {
                            Text("No Images Available")
                                .foregroundStyle(.secondary)
                                .font(.headline)
                        }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "x.circle.fill")
                            .foregroundStyle(.gray)
                            .font(.system(size: 25))
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
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
