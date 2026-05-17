import Foundation

struct TripItem: Identifiable, Hashable, Sendable {
    let booking: Booking
    let listing: Listing

    var id: String { booking.id }
}
