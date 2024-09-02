//
//  PublicProfileView.swift
//  Clin
//
//  Created by asia on 31/08/2024.
//

import SwiftUI

struct PublicProfileView: View {
    var viewModel: PublicProfileViewModel
    
    var body: some View {
        HStack {
            ZStack {
                CircularProfileView(size: .xLarge, profile: viewModel.profile)
            }
            .scaledToFill()
            .clipShape(Circle())
            .frame(width: 80, height: 80)
            
            Text("\(viewModel.displayName)")
                .font(.title3)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .padding(.leading)
        }
    }
}

#Preview {
    PublicProfileView(viewModel: PublicProfileViewModel(sellerID: UUID()))
}
