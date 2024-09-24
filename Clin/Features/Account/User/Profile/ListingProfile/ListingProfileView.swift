//
//  PublicProfileView.swift
//  Clin
//
//  Created by asia on 31/08/2024.
//

import SwiftUI

struct ListingProfileView: View {
    var viewModel: ListingProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                CircularProfileView(size: .xLarge, profile: viewModel.profile)
                    .frame(width: 80, height: 80)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                    
                    if viewModel.profile?.isDealer ?? false {
                        Text("Verified Dealer")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.tabColour.opacity(0.1))
                            .foregroundStyle(.tabColour)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    
                    Text("Member since \(viewModel.memberSince.formatted(date: .long, time: .omitted))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            
            if viewModel.profile?.isDealer ?? false {
                dealerInfoView
            }
        }
        .padding()
    }
    
    private var dealerInfoView: some View {
        VStack(alignment: .leading, spacing: 8) {
            infoRow(icon: "mappin", text: viewModel.address)
            infoRow(icon: "location", text: "\(viewModel.postcode), \(viewModel.location)")
            websiteRow
            infoRow(icon: "building.2", text: "Company No: \(viewModel.companyNumber)")
        }
        .font(.footnote)
    }
    
    private func infoRow(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.gray)
                .frame(width: 20)
            Text(text)
                .lineLimit(1)
        }
    }
    
    private var websiteRow: some View {
        HStack(spacing: 8) {
            Image(systemName: "link")
                .foregroundStyle(.gray)
                .frame(width: 20)
            if let url = URL(string: viewModel.website), viewModel.website.starts(with: "https://") {
                Link(viewModel.website, destination: url)
                    .lineLimit(1)
                    .foregroundStyle(.blue)
            } else {
                Text(viewModel.website)
                    .lineLimit(1)
            }
        }
    }
}

#Preview {
    ListingProfileView(viewModel: ListingProfileViewModel(sellerID: UUID()))
}
