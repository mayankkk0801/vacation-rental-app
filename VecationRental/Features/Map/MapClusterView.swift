import Combine
import MapKit
import SwiftUI

private let defaultMapRegion = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
    span: MKCoordinateSpan(latitudeDelta: 0.35, longitudeDelta: 0.35)
)

struct MapClusterView: View {
    @StateObject private var viewModel = MapViewModel()
    @EnvironmentObject private var appState: AppState
    @State private var selectedListing: Listing?
    @State private var cameraPosition: MapCameraPosition = .region(defaultMapRegion)
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .bottom) {
                Map(position: $cameraPosition) {
                    ForEach(viewModel.annotations) { item in
                        Annotation(item.listing.title, coordinate: item.coordinate) {
                            MapPinView(
                                price: item.listing.formattedPrice,
                                isSelected: selectedListing?.id == item.listing.id
                            )
                            .onTapGesture {
                                selectedListing = item.listing
                                viewModel.select(listing: item.listing)
                                updateCamera()
                                Haptics.selection()
                            }
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .including([.park, .museum])))

                if let listing = selectedListing {
                    ListingMapPreviewCard(listing: listing) {
                        selectedListing = nil
                    } onViewStay: {
                        navigationPath.append(listing)
                    }
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Listing.self) { listing in
                ListingDetailView(listing: listing)
                    .environmentObject(appState)
            }
            .onAppear {
                viewModel.load()
                updateCamera()
            }
            .onChange(of: viewModel.annotations.count) { _, _ in
                updateCamera()
            }
            .onChange(of: appState.selectedTab) { _, tab in
                if tab != .map {
                    navigationPath = NavigationPath()
                    selectedListing = nil
                }
            }
        }
    }

    private func updateCamera() {
        if let region = viewModel.region {
            cameraPosition = .region(region)
        } else {
            cameraPosition = .region(defaultMapRegion)
        }
    }
}

struct MapPinView: View {
    let price: String
    let isSelected: Bool

    var body: some View {
        Text(price)
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color(.systemBackground))
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .clipShape(Capsule())
            .shadow(radius: 4)
            .accessibilityLabel("Listing priced \(price)")
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct ListingMapPreviewCard: View {
    let listing: Listing
    var onDismiss: () -> Void
    var onViewStay: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(listing.title).font(.headline)
                    Text(listing.locationLabel).font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Dismiss map preview")
            }
            Button(action: onViewStay) {
                Text("View stay")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .contain)
    }
}

@MainActor
final class MapViewModel: ObservableObject {
    @Published private(set) var annotations: [ListingAnnotation] = []
    @Published private(set) var region: MKCoordinateRegion?

    private let repository: ListingRepositoryProtocol
    private let analytics: AnalyticsServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var hasSubscribed = false

    init(
        repository: ListingRepositoryProtocol = ListingRepository.shared,
        analytics: AnalyticsServiceProtocol = AnalyticsService.shared
    ) {
        self.repository = repository
        self.analytics = analytics
    }

    func load() {
        guard !hasSubscribed else { return }
        hasSubscribed = true
        repository.observeListings()
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { [weak self] listings in
                self?.annotations = listings.map(ListingAnnotation.init)
                self?.region = Self.region(for: listings)
            }
            .store(in: &cancellables)
    }

    func select(listing: Listing) {
        analytics.track(.mapClusterTapped)
        region = MKCoordinateRegion(
            center: listing.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }

    private static func region(for listings: [Listing]) -> MKCoordinateRegion? {
        guard !listings.isEmpty else { return nil }
        let latitudes = listings.map(\.latitude)
        let longitudes = listings.map(\.longitude)
        let center = CLLocationCoordinate2D(
            latitude: (latitudes.min()! + latitudes.max()!) / 2,
            longitude: (longitudes.min()! + longitudes.max()!) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max(0.08, (latitudes.max()! - latitudes.min()!) * 1.4),
            longitudeDelta: max(0.08, (longitudes.max()! - longitudes.min()!) * 1.4)
        )
        return MKCoordinateRegion(center: center, span: span)
    }
}

struct ListingAnnotation: Identifiable {
    let id: String
    let listing: Listing
    var coordinate: CLLocationCoordinate2D { listing.coordinate }

    init(listing: Listing) {
        id = listing.id
        self.listing = listing
    }
}
