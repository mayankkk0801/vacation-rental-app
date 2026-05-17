import SwiftUI

struct TripsView: View {
    @StateObject private var viewModel = TripsViewModel()
    @EnvironmentObject private var appState: AppState
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if viewModel.trips.isEmpty {
                    ContentUnavailableView(
                        "No trips yet",
                        systemImage: "suitcase",
                        description: Text("Confirmed bookings will appear here after checkout.")
                    )
                } else {
                    List(viewModel.trips) { trip in
                        NavigationLink(value: trip.listing) {
                            TripRowView(trip: trip)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Trips")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Listing.self) { listing in
                ListingDetailView(listing: listing)
                    .environmentObject(appState)
            }
            .onChange(of: appState.selectedTab) { _, tab in
                if tab != .trips {
                    navigationPath = NavigationPath()
                }
            }
        }
    }
}

struct TripRowView: View {
    let trip: TripItem

    var body: some View {
        HStack(spacing: 12) {
            ListingImageView(source: trip.listing.primaryImageSource)
                .frame(width: 88, height: 88)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 6) {
                Text(trip.listing.title)
                    .font(.headline)
                Text(trip.listing.locationLabel)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(trip.booking.checkIn.formatted(date: .abbreviated, time: .omitted)) – \(trip.booking.checkOut.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(totalLabel)
                    .font(.subheadline.bold())
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }

    private var totalLabel: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = trip.booking.currencyCode
        let total = formatter.string(from: trip.booking.total as NSDecimalNumber) ?? "\(trip.booking.total)"
        return "\(total) · Confirmed"
    }
}
