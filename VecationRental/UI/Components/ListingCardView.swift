import SwiftUI

struct ListingCardView: View {
    let listing: Listing
    var layout: ListingCardLayout = .hero

    enum ListingCardLayout {
        case hero
        case compact
    }

    init(listing: Listing) {
        self.listing = listing
        let variant = AnalyticsService.shared.experimentVariant(for: .listingCardLayout)
        layout = variant == "compact" ? .compact : .hero
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ListingImageView(source: listing.primaryImageSource)
                .frame(height: layout == .hero ? 200 : 140)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(listing.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(listing.locationLabel)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack {
                    Label(String(format: "%.2f", listing.rating), systemImage: "star.fill")
                        .font(.subheadline)
                    Spacer()
                    Text("\(listing.formattedPrice) / night")
                        .font(.subheadline.bold())
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(listing.title) in \(listing.locationLabel). Rated \(listing.rating). \(listing.formattedPrice) per night.")
        .accessibilityHint("Opens listing details")
    }
}

struct ListingRowView: View {
    let listing: Listing

    var body: some View {
        HStack(spacing: 12) {
            ListingImageView(source: listing.primaryImageSource)
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading) {
                Text(listing.title).font(.headline)
                Text(listing.locationLabel).font(.caption).foregroundStyle(.secondary)
                Text("\(listing.formattedPrice) / night").font(.subheadline.bold())
            }
        }
        .accessibilityElement(children: .combine)
    }
}
