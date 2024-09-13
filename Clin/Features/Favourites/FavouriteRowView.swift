//
//  FavouriteCell.swift
//  Clin
//
//  Created by asia on 25/07/2024.
//

import SwiftUI

struct FavouriteRowView: View {
    let favourite: Favourite
    let action: () async -> Void
    @State private var showDeleteAlert = false
   
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                imageView
                headerView
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Label {
                            Text(favourite.condition)
                        } icon: {
                            Image(systemName: "car.fill")
                        }

                        Label {
                            Text("\(favourite.price, format: .number) miles")
                        } icon: {
                            Image(systemName: "speedometer")
                        }
                        
                        Label {
                            Text(favourite.numberOfOwners)
                        } icon: {
                            Image(systemName: "person.2.fill")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(favourite.bodyType)
                        Text("\(favourite.powerBhp) BHP")
                        Text(favourite.range)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                
                Divider()
                
                HStack {
                    Text(favourite.price, format: .currency(code: Locale.current.currency?.identifier ?? "GBP").precision(.fractionLength(0)))
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text(favourite.location)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Text("\(favourite.serviceHistory) service history")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .fontDesign(.rounded).bold()
        .frame(maxWidth: .infinity, maxHeight: 250)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(alignment: .topTrailing) {
            deleteButton
        }
        .deleteAlert(
            isPresented: $showDeleteAlert,
            itemToDelete: .constant(favourite),
            deleteAction: { _ in await action() }
        )
       
    }
    
    private var imageView: some View {
        Group {
            if let firstImageURL = favourite.thumbnailsURL.first {
                ImageLoader(url: firstImageURL, contentMode: .fill, targetSize: CGSize(width: 80, height: 80))
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Rectangle()
                    .foregroundStyle(.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        ProgressView()
                            .scaleEffect(1.2)
                    }
            }
        }
    }
    
    private var headerView: some View {
        Text("\(favourite.make) \(favourite.model)")
            .font(.headline)
            .lineLimit(2)
    }
    
    private var deleteButton: some View {
        Button(action: {
            showDeleteAlert.toggle()
        }) {
            Image(systemName: "trash")
                .foregroundStyle(.red.gradient)
        }
        .buttonStyle(.plain)
        .padding()
    }
}

#Preview {
    FavouriteRowView(favourite: MockFavouriteService.sampleData[0], action: {})
        .previewLayout(.sizeThatFits)
        .padding()
}
