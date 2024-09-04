//
//  AddToFavouritesButton.swift
//  Clin
//
//  Created by asia on 25/07/2024.
//

import SwiftUI

struct AddToFavouritesButton: View {
    @Environment(FavouriteViewModel.self) private var viewModel
    var listing: Listing
    let iconSize: CGFloat
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        Button(action: toggleFavourite) {
            FavouriteButtonBackground(width: width, height: height) {
                FavouriteIcon(
                    isPromoted: listing.isPromoted,
                    isFavourite: viewModel.isFavourite(listing: listing),
                    iconSize: iconSize
                )
            }
        }
        .buttonStyle(.plain)
        .padding(.trailing, 5)
        .padding(.top, 5)
    }
    
    private func toggleFavourite() {
        Task {
            try await viewModel.toggleFavourite(for: listing)
        }
    }
}

struct FavouriteButtonBackground<Content: View>: View {
    let width: CGFloat
    let height: CGFloat
    let content: () -> Content
    
    var body: some View {
        Circle()
            .frame(width: width, height: height)
            .opacity(0.6)
            .foregroundStyle(Color(.systemGray6))
            .overlay {
                content()
            }
    }
}

struct FavouriteIcon: View {
    let isPromoted: Bool
    let isFavourite: Bool
    let iconSize: CGFloat
    
    var body: some View {
        Image(systemName: imageName)
            .font(.system(size: iconSize))
            .foregroundStyle(foregroundStyle)
            .fontWeight(.bold)
            .symbolEffect(.bounce, value: isFavourite)
            .sensoryFeedback(.impact(flexibility: .soft), trigger: isFavourite)
    }
    
    private var imageName: String {
        isPromoted
            ? (isFavourite ? "crown.fill" : "crown")
            : (isFavourite ? "heart.fill" : "heart")
    }
    
    private var foregroundStyle: some ShapeStyle {
        isPromoted ? .yellow : .green
    }
}

#Preview {
    AddToFavouritesButton(listing: MockListingService.sampleData[0], iconSize: 18, width: 30, height: 30)
        .environment(FavouriteViewModel())
}
