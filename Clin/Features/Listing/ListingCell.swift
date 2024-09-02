
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
            promotedBadge
                .opacity(listing.isPromoted ? 1 : 0)
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
        ZStack {
            Rectangle()
                .frame(width: 35, height: 18)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 0, bottomTrailingRadius: 5, topTrailingRadius: 0, style: .continuous))
                .foregroundStyle(.yellow.gradient)
            
            Image(systemName: "p.circle")
                .font(.system(size: 12))
                .foregroundStyle(.primary)
        }
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
                .foregroundStyle(listing.isPromoted ? .yellow : .primary)
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
        .fontDesign(.rounded).bold()
        .padding(.leading, 5)
    }
}

#Preview {
    ListingCell(listing: MockListingService.sampleData[0], showFavourite: true)
        .previewLayout(.sizeThatFits)
        .environment(FavouriteViewModel())
}
