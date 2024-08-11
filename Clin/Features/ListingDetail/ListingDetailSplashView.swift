//
//  ListingDetailSplashView.swift
//  Clin
//
//  Created by asia on 11/08/2024.
//

import SwiftUI

struct ListingDetailSplashView: View {
    @State private var isAnimating: Bool = false
    var listing: Listing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .foregroundStyle(.gray.opacity(0.5))
                .frame(maxWidth: .infinity, maxHeight: 350)
                .overlay {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            VStack(alignment: .leading, spacing: 5) {
                Text("\(listing.make) \(listing.model)")
                    .font(.title)
                    .fontWeight(.bold)
                
            }
            .padding()
            
            Spacer()
        }
        
        VStack(alignment: .center, spacing: 0) {
            Image(systemName: "ellipsis")
                .symbolEffect(.bounce, options: .repeating.speed(0.8), value: isAnimating)
                .font(.system(size: 60))
                .onAppear {
                    isAnimating.toggle()
                }
                .onDisappear {
                    isAnimating = false
                }
        }
        .padding(.bottom, 150)
    }
}

#Preview {
    ListingDetailSplashView(listing: MockListingService.sampleData[0])
}
