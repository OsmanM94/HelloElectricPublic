//
//  ListingDetailView.swift
//  Clin
//
//  Created by asia on 05/08/2024.
//

import SwiftUI

struct ListingDetailView: View {
    @State private var showSheet: Bool = false
    @State private var showSplash: Bool = true
    var listing: Listing
    
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
                            Text("\(listing.make) \(listing.model)")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("\(listing.condition)")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                            
                            Text("\(listing.mileage, format: .number) miles")
                                .font(.title3)
                            
                            Text(listing.price, format: .currency(code: Locale.current.currency?.identifier ?? "GBP").precision(.fractionLength(0)))
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        .padding()
                        
                        Spacer()
                    }
//                    .onDisappear {
//                        ImagePrefetcher.instance.clearCache()
//                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ListingDetailView(listing: MockListingService.sampleData[0])
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

