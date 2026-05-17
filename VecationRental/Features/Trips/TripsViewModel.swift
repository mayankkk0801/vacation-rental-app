import Combine
import Foundation

@MainActor
final class TripsViewModel: ObservableObject {
    @Published private(set) var trips: [TripItem] = []

    private let bookingRepository: BookingRepositoryProtocol
    private let listingLookup: (String) -> Listing?
    private var cancellables = Set<AnyCancellable>()

    init(
        bookingRepository: (any BookingRepositoryProtocol)? = nil,
        listingLookup: @escaping (String) -> Listing? = { ListingCatalog.listing(id: $0) }
    ) {
        self.bookingRepository = bookingRepository ?? BookingRepository.shared
        self.listingLookup = listingLookup
        bind()
    }

    private func bind() {
        bookingRepository.observeBookings()
            .receive(on: DispatchQueue.main)
            .map { [listingLookup] bookings in
                bookings.compactMap { booking -> TripItem? in
                    guard let listing = listingLookup(booking.listingID) else { return nil }
                    return TripItem(booking: booking, listing: listing)
                }
            }
            .sink { [weak self] trips in
                self?.trips = trips
            }
            .store(in: &cancellables)
    }
}
