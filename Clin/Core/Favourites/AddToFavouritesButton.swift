//
//  AddToFavouritesButton.swift
//  Clin
//
//  Created by asia on 25/07/2024.
//

import SwiftUI

struct AddToFavouritesButton: View {
    @EnvironmentObject private var favouriteViewModel: FavouriteViewModel
    @State private var isFavorite: Bool = false
    let listing: Listing
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
                favouriteViewModel.addToFavorites(listing: listing)
            } label: {
                Circle()
                    .frame(width: 30, height: 30)
                    .opacity(0.5)
                    .foregroundStyle(Color(.white))
                    .overlay {
                        Image(systemName: favouriteViewModel.isFavorite(listing: listing) ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundStyle(.green)
                            .fontWeight(.bold)
                            .symbolEffect(.bounce, value: favouriteViewModel.isFavorite(listing: listing))
                            .sensoryFeedback(.impact(flexibility: .soft), trigger: favouriteViewModel.isFavorite(listing: listing))
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
        .environmentObject(FavouriteViewModel())
}
