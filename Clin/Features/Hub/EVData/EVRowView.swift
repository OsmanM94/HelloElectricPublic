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
            
            VStack(alignment: .leading, spacing: 12) {
                carNameAndYear
                specsView
                secondSpecsView
            }
        }
    }
    
    private var carImage: some View {
        Group {
            if let imageURL = ev.image1?.first {
                ImageLoader(url: imageURL, contentMode: .fill, targetSize: CGSize(width: 130, height: 130))
                    .frame(width: 130, height: 130)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 130, height: 130)
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
        VStack(spacing: 4) {
            Text("Price")
                .font(.caption)
                .foregroundStyle(.tabColour)
            Text(ev.carPrice ?? 0, format: .currency(code: Locale.current.currency?.identifier ?? "GBP").precision(.fractionLength(0)))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var specsView: some View {
        HStack {
            specItem(text: "Top Speed", value: ev.performanceTopSpeed ?? "N/A")
            Spacer()
            
            specItemNumeric(text: "Range", value: ev.electricRange ?? 0, type: "mi")
            Spacer()
            
            specItemNumeric(text: "0-62", value: ev.performanceAcceleration0_62_Mph ?? 0, type: "sec")
        }
    }
    
    private var secondSpecsView: some View {
        HStack {
            specItem(text: "Rapid Charge", value: ev.chargingRapidChargeSpeed ?? "N/A")
            Spacer()
            specItemNumeric(text: "Efficiency", value: ev.efficiencyRealRangeConsumption ?? 0, type: "Wh/mi")
            Spacer()
            priceView
        }
    }
    
    private func specItem(text: String, value: String) -> some View {
            VStack(alignment: .leading, spacing: 2) {
                Text(text)
                    .font(.caption2)
                    .foregroundStyle(.tabColour)
                Text(value)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        
        private func specItemNumeric(text: String, value: Int, type: String) -> some View {
            VStack(alignment: .leading, spacing: 2) {
                Text(text)
                    .font(.caption2)
                    .foregroundStyle(.tabColour)
                
                Text("\(value) \(type)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
}

#Preview {
    EVRowView(ev: EVDatabase.sampleData)
}

