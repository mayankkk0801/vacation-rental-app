import Combine
import MapKit
import SwiftUI

struct ListingDetailView: View {
    let listing: Listing

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @StateObject private var reviewsViewModel: ReviewsViewModel
    @State private var showCheckout = false
    @State private var route: MKRoute?
    @State private var cameraPosition: MapCameraPosition = .automatic

    private let analytics = AnalyticsService.shared
    private let checkoutCTA: String

    init(listing: Listing) {
        self.listing = listing
        _reviewsViewModel = StateObject(wrappedValue: ReviewsViewModel(listingID: listing.id))
        checkoutCTA = AnalyticsService.shared.experimentVariant(for: .checkoutCTA) == "reserve_now"
            ? "Reserve now"
            : "Book stay"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                hero
                header
                amenityGrid
                neighborhoodMap
                reviewsSection
            }
            .padding(.bottom, 88)
        }
        .navigationTitle(listing.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    Haptics.selection()
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                .accessibilityLabel("Back to listings")
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                Haptics.lightImpact()
                analytics.track(.checkoutStarted)
                showCheckout = true
            } label: {
                Text("\(checkoutCTA) · \(listing.formattedPrice) / night")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .background(.ultraThinMaterial)
            .accessibilityLabel("\(checkoutCTA). \(listing.formattedPrice) per night")
        }
        .sheet(isPresented: $showCheckout) {
            CheckoutView(draft: BookingDraft(
                listing: listing,
                checkIn: Date().addingTimeInterval(86400 * 3),
                checkOut: Date().addingTimeInterval(86400 * 6),
                guestCount: 2
            ))
            .environmentObject(appState)
        }
        .onAppear {
            analytics.track(.listingOpened)
            cameraPosition = .region(MKCoordinateRegion(
                center: listing.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            ))
            loadRoutePreview()
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            ListingPhotoGallery(listing: listing, height: 280)
            LinearGradient(colors: [.clear, .black.opacity(0.55)], startPoint: .center, endPoint: .bottom)
                .allowsHitTesting(false)
            VStack(alignment: .leading) {
                Text(listing.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding()
            .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(String(format: "%.2f", listing.rating), systemImage: "star.fill")
                Text("(\(listing.reviewCount) reviews)")
                    .foregroundStyle(.secondary)
            }
            Text(listing.description)
            Label("\(listing.bedrooms) bed · \(listing.bathrooms) bath · \(listing.maxGuests) guests", systemImage: "person.2")
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

    private var amenityGrid: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Amenities").font(.headline)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 8)]) {
                ForEach(listing.amenities, id: \.self) { amenity in
                    Label(amenity, systemImage: "checkmark.circle")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.horizontal)
    }

    private var neighborhoodMap: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Neighborhood").font(.headline)
            Text("Explore \(listing.neighborhood) — local highlights and transit nearby.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Map(position: $cameraPosition) {
                Marker(listing.neighborhood, coordinate: listing.coordinate)
                if let route {
                    MapPolyline(route.polyline)
                        .stroke(Color.accentColor, lineWidth: 4)
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            if route != nil {
                Text("Route preview from city center")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
    }

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reviews").font(.headline)
            ForEach(reviewsViewModel.reviews) { review in
                ReviewRow(review: review)
            }
        }
        .padding(.horizontal)
    }

    private func loadRoutePreview() {
        let request = MKDirections.Request()
        request.source = MapDirectionsHelper.mapItem(
            latitude: 37.7799,
            longitude: -122.4194
        )
        request.destination = MapDirectionsHelper.mapItem(
            latitude: listing.latitude,
            longitude: listing.longitude
        )
        request.transportType = .automobile
        MKDirections(request: request).calculate { response, _ in
            route = response?.routes.first
        }
    }
}

private enum MapDirectionsHelper {
    static func mapItem(latitude: Double, longitude: Double) -> MKMapItem {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        if #available(iOS 26.0, *) {
            return MKMapItem(location: CLLocation(latitude: latitude, longitude: longitude), address: nil)
        }
        return MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
    }
}

struct ReviewRow: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(review.authorName).font(.subheadline.bold())
                Spacer()
                Text("\(review.rating)/5")
                    .accessibilityLabel("Rating \(review.rating) out of 5")
            }
            Text(review.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

@MainActor
final class ReviewsViewModel: ObservableObject {
    @Published private(set) var reviews: [Review] = []
    private var cancellables = Set<AnyCancellable>()

    init(listingID: String, repository: ListingRepositoryProtocol = ListingRepository.shared) {
        repository.observeReviews(listingID: listingID)
            .receive(on: DispatchQueue.main)
            .replaceError(with: [])
            .assign(to: &$reviews)
    }
}
