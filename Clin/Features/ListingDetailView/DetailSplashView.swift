//
//  DetailSplashView.swift
//  Clin
//
//  Created by asia on 10/09/2024.
//
import SwiftUI

struct DetailSplashView: View {
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
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Tesla Model 3 2024")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Used")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text("120,000 miles")
                    .font(.title3)
                Text("£17,000")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Divider()
                
                HStack(spacing: 15) {
                    Image(systemName: "gauge.with.needle")
                        .font(.system(size: 24))
                        .foregroundStyle(.secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Mileage")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("120.000 miles")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(0..<2) { _ in
                        Rectangle()
                            .frame(maxWidth: .infinity, minHeight: 100)
                           
                            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 12, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 12, style: .continuous))
                    }
                }
                .foregroundStyle(.gray.opacity(0.5))
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
    DetailSplashView()
}
