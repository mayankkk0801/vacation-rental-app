import Foundation

struct SearchFilters: Equatable, Sendable {
    var query: String = ""
    var minPrice: Decimal?
    var maxPrice: Decimal?
    var minBedrooms: Int?
    var minBathrooms: Int?
    var minGuests: Int?
    var amenities: Set<String> = []
    var neighborhood: String?
    var availableOnly: Bool = true
    var sort: SortOption = .recommended

    enum SortOption: String, CaseIterable, Identifiable, Sendable {
        case recommended
        case priceLowToHigh
        case priceHighToLow
        case rating

        var id: String { rawValue }

        var label: String {
            switch self {
            case .recommended: return "Recommended"
            case .priceLowToHigh: return "Price: low to high"
            case .priceHighToLow: return "Price: high to low"
            case .rating: return "Top rated"
            }
        }
    }

    var activeFilterCount: Int {
        var count = 0
        if minPrice != nil { count += 1 }
        if maxPrice != nil { count += 1 }
        if minBedrooms != nil { count += 1 }
        if minBathrooms != nil { count += 1 }
        if minGuests != nil { count += 1 }
        if !amenities.isEmpty { count += 1 }
        if neighborhood != nil { count += 1 }
        return count
    }

    func matches(_ listing: Listing) -> Bool {
        if availableOnly && !listing.isAvailable { return false }
        if !query.isEmpty {
            let haystack = "\(listing.title) \(listing.subtitle) \(listing.city) \(listing.neighborhood)".lowercased()
            if !haystack.contains(query.lowercased()) { return false }
        }
        if let minPrice, listing.nightlyPrice < minPrice { return false }
        if let maxPrice, listing.nightlyPrice > maxPrice { return false }
        if let minBedrooms, listing.bedrooms < minBedrooms { return false }
        if let minBathrooms, listing.bathrooms < minBathrooms { return false }
        if let minGuests, listing.maxGuests < minGuests { return false }
        if let neighborhood, !listing.neighborhood.localizedCaseInsensitiveContains(neighborhood) {
            return false
        }
        if !amenities.isEmpty {
            let listingAmenities = Set(listing.amenities.map { $0.lowercased() })
            let required = Set(amenities.map { $0.lowercased() })
            if !required.isSubset(of: listingAmenities) { return false }
        }
        return true
    }

    func sorted(_ listings: [Listing]) -> [Listing] {
        switch sort {
        case .recommended:
            return listings.sorted { $0.rating * Double($0.reviewCount) > $1.rating * Double($1.reviewCount) }
        case .priceLowToHigh:
            return listings.sorted { $0.nightlyPrice < $1.nightlyPrice }
        case .priceHighToLow:
            return listings.sorted { $0.nightlyPrice > $1.nightlyPrice }
        case .rating:
            return listings.sorted { $0.rating > $1.rating }
        }
    }
}
