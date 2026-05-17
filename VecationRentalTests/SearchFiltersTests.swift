import XCTest
@testable import VecationRental

final class SearchFiltersTests: XCTestCase {
    func testMatchesPriceAndBedrooms() {
        let listing = Listing.preview
        var filters = SearchFilters()
        filters.minPrice = 100
        filters.maxPrice = 200
        filters.minBedrooms = 2
        XCTAssertTrue(filters.matches(listing))
    }

    func testSortByRating() {
        let listings = Listing.previews
        var filters = SearchFilters()
        filters.sort = .rating
        let sorted = filters.sorted(listings)
        XCTAssertEqual(sorted.first?.rating, listings.map(\.rating).max())
    }
}
