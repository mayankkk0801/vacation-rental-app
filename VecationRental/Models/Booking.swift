import Foundation

struct Booking: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let listingID: String
    var checkIn: Date
    var checkOut: Date
    var guestCount: Int
    var subtotal: Decimal
    var serviceFee: Decimal
    var taxes: Decimal
    var currencyCode: String
    var status: BookingStatus
    var createdAt: Date

    var total: Decimal { subtotal + serviceFee + taxes }

    var nightCount: Int {
        max(1, Calendar.current.dateComponents([.day], from: checkIn, to: checkOut).day ?? 1)
    }
}

enum BookingStatus: String, Codable, Sendable {
    case draft
    case pendingPayment
    case confirmed
    case cancelled
}

struct BookingDraft: Sendable {
    let listing: Listing
    var checkIn: Date
    var checkOut: Date
    var guestCount: Int

    func makeBooking(id: String = UUID().uuidString) -> Booking {
        let nights = Decimal(max(1, Calendar.current.dateComponents([.day], from: checkIn, to: checkOut).day ?? 1))
        let subtotal = listing.nightlyPrice * nights
        let serviceFee = (subtotal * Decimal(0.12)).rounded(scale: 2)
        let taxes = (subtotal * Decimal(0.085)).rounded(scale: 2)
        return Booking(
            id: id,
            listingID: listing.id,
            checkIn: checkIn,
            checkOut: checkOut,
            guestCount: guestCount,
            subtotal: subtotal,
            serviceFee: serviceFee,
            taxes: taxes,
            currencyCode: listing.currencyCode,
            status: .pendingPayment,
            createdAt: Date()
        )
    }
}

private extension Decimal {
    func rounded(scale: Int) -> Decimal {
        var value = self
        var result = Decimal()
        NSDecimalRound(&result, &value, scale, .plain)
        return result
    }
}
