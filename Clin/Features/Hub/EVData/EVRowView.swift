//
//  EVRowView.swift
//  Clin
//
//  Created by asia on 13/09/2024.
//

import SwiftUI

struct EVRowView: View {
    let ev: EVDatabase
    
    var body: some View {
        HStack(spacing: 16) {
            carImage
            
            VStack(alignment: .leading, spacing: 8) {
                carNameAndYear
                priceView
                specsView
            }
        }
    }
    
    private var carImage: some View {
        Group {
            if let imageURL = ev.image1?.first {
                ImageLoader(url: imageURL, contentMode: .fill, targetSize: CGSize(width: 100, height: 100))
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "car.fill")
                            .foregroundStyle(.gray)
                            .font(.system(size: 40))
                    )
            }
        }
        .shadow(radius: 2)
    }
    
    private var carNameAndYear: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(ev.carName ?? "N/A")
                .font(.headline)
                .foregroundStyle(.primary)
            Text(ev.availableSince ?? "N/A")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var priceView: some View {
        Text(ev.carPrice ?? 0, format: .currency(code: Locale.current.currency?.identifier ?? "GBP").precision(.fractionLength(0)))
            .font(.title3)
            .fontWeight(.bold)
            .foregroundStyle(.green.gradient)
    }
    
    private var specsView: some View {
        HStack(spacing: 16) {
            specItem(icon: "bolt.car", value: ev.electricRange ?? "N/A")
            specItem(icon: "fuelpump", value: ev.efficiencyRealRangeConsumption ?? "N/A")
            specItem(icon: "link", value: ev.dimensionsTow == "Yes" ? "Towing" : "No towing")
        }
    }
    
    private func specItem(icon: String, value: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(.gray)
            Text(value)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    EVRowView(ev: EVDatabase.sampleData)
}

