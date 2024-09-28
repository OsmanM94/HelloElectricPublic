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
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Used")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "heart")
            }
            Text("Tesla Model 3 2024")
                .font(.title2)
            
            Text("120,000 miles")
                .font(.title3)
            
            Divider()
            
            Text("£17,000")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 15) {
                Image(systemName: "gauge.with.needle")
                    .font(.system(size: 24))
                   
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mileage")
                        .font(.subheadline)
                   
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
            .foregroundStyle(.gray.opacity(0.3))
        }
        .padding()
        .onAppear {
            isAnimating.toggle()
        }
        .onDisappear {
            isAnimating = false
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("Listing ID")
                    .font(.caption)
            }
        }
        .redacted(reason: .placeholder)
    }
}

#Preview {
    NavigationStack {
        DetailSplashView()
    }
}
