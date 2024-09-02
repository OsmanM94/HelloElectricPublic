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
        VStack(spacing: 0) {
            Button {
                Task {
                    try await viewModel.toggleFavourite(for: listing)
                }
            } label: {
                Circle()
                    .frame(width: width, height: height)
                    .opacity(0.6)
                    .foregroundStyle(Color(.systemGray6))
                    .overlay {
                        Image(systemName: viewModel.isFavourite(listing: listing) ? "heart.fill" : "heart")
                            .font(.system(size: iconSize))
                            .foregroundStyle(listing.isPromoted ? .yellow : .green)
                            .fontWeight(.bold)
                            .symbolEffect(.bounce, value: viewModel.isFavourite(listing: listing))
                            .sensoryFeedback(.impact(flexibility: .soft), trigger: viewModel.isFavourite(listing: listing))
                    }
            }
            .padding(.trailing, 5)
            .padding(.top, 5)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AddToFavouritesButton(listing: MockListingService.sampleData[0], iconSize: 18, width: 30, height: 30)
        .environment(FavouriteViewModel())
}
