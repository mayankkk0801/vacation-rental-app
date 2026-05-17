import XCTest
@testable import VecationRental

final class BookingTests: XCTestCase {
    func testBookingDraftTotals() {
        let draft = BookingDraft(
            listing: .preview,
            checkIn: Date(),
            checkOut: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
            guestCount: 2
        )
        let booking = draft.makeBooking()
        XCTAssertGreaterThan(booking.total, booking.subtotal)
        XCTAssertEqual(booking.nightCount, 3)
    }
}
