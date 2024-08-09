//
//  AddToFavouritesButton.swift
//  Clin
//
//  Created by asia on 25/07/2024.
//

import SwiftUI

struct AddToFavouritesButton: View {
    @EnvironmentObject private var viewModel: FavouriteViewModel
    var listing: Listing
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
                Task {
                    try await viewModel.toggleFavourite(for: listing)
                }
            } label: {
                Circle()
                    .frame(width: 30, height: 30)
                    .opacity(0.8)
                    .foregroundStyle(Color(.white))
                    .overlay {
                        Image(systemName: viewModel.isFavourite(listing: listing) ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundStyle(.green)
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
    AddToFavouritesButton(listing: MockListingService.sampleData[0])
        .environmentObject(FavouriteViewModel(favouriteService: MockFavouriteService()))
        .preferredColorScheme(.dark)
}
