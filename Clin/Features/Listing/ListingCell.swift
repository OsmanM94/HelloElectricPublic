
import SwiftUI


struct ListingCell: View {
    @State private var timerManager = TimerManager()
    let listing: Listing
    let showFavourite: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            listingImage
            listingDetails
        }
        .onAppear {
            timerManager.startListingTimer(interval: 60)
        }
    }
    
    private var listingImage: some View {
        VStack(spacing: 0) {
            if let firstImageURL = listing.thumbnailsURL.first {
                ImageLoader(url: firstImageURL, contentMode: .fill, targetSize: CGSize(width: 120, height: 120))
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                placeholderImage
            }
        }
        .overlay(alignment: .topTrailing) {
            topRightOverlay
        }
        .overlay(alignment: .topLeading) {
            if listing.isPromoted {
                promotedBadge
            }
        }
    }
    
    private var placeholderImage: some View {
        Rectangle()
            .foregroundStyle(.gray.opacity(0.5))
            .frame(width: 120, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                ProgressView()
                    .scaleEffect(1.2)
            }
    }
    
    private var topRightOverlay: some View {
        Group {
            if showFavourite {
                AddToFavouritesButton(listing: listing, iconSize: 18, width: 30, height: 30)
            } else {
                activeStatusBadge
            }
        }
    }
    
    private var promotedBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.system(size: 10))
            Text("Promoted")
                .font(.system(size: 10, weight: .semibold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGray6).opacity(0.8))
        .foregroundColor(.yellow)
        .cornerRadius(5)
        
    }
    
    private var activeStatusBadge: some View {
        HStack(spacing: 2) {
            Circle()
                .frame(width: 8, height: 8)
                .foregroundStyle(.green.gradient)
            Text("Active")
                .font(.caption2)
        }
        .padding(.trailing, 6)
        .padding(.bottom, 5)
        .padding(.top, 5)
        .padding(.leading, 6)
        .background(Color(.systemBackground).opacity(0.8), in: RoundedRectangle(cornerRadius: 5))
        .padding(.all, 4)
    }
    
    private var listingDetails: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("\(listing.make) \(listing.model) \(listing.yearOfManufacture)")
                .font(.headline)
                .lineLimit(2, reservesSpace: false)
            Text("\(listing.condition)")
                .foregroundStyle(.secondary)
                .font(.subheadline)
            Text("\(listing.mileage, format: .number) miles")
                .font(.subheadline)
            Text(listing.price, format: .currency(code: Locale.current.currency?.identifier ?? "GBP").precision(.fractionLength(0)))
                .font(.subheadline)
            Text("added \(listing.createdAt.timeElapsedString())")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.leading, 5)
    }
}

#Preview {
    ListingCell(listing: MockListingService.sampleData[0], showFavourite: true)
        .previewLayout(.sizeThatFits)
        .environment(FavouriteViewModel())
}



