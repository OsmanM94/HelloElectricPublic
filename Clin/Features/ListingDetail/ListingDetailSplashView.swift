//
//  ListingDetailSplashView.swift
//  Clin
//
//  Created by asia on 11/08/2024.
//

import SwiftUI

struct ListingDetailSplashView: View {
    @State private var isAnimating: Bool = false
   
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
                Text("Tesla model 3 2024 ")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Used")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                
                Text("120.000 miles")
                    .font(.title3)
                
                Text("£17.000")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .shimmer(when: $isAnimating)
            .padding()
           
            Spacer()
        }
        .onAppear {
            isAnimating.toggle()
        }
        .onDisappear {
            isAnimating = false
        }
    }
}

#Preview {
    ListingDetailSplashView()
}
