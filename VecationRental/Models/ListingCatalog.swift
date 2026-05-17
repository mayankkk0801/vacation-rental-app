import Foundation

enum ListingCatalog {
    /// Bundled asset names in Assets.xcassets (`{prefix}-0` … `{prefix}-3`).
    static func assets(_ prefix: String) -> [String] {
        (0..<4).map { "\(prefix)-\($0)" }
    }

    static let all: [Listing] = [
        Listing(
            id: "preview-1",
            title: "Oceanview Loft",
            subtitle: "Steps from the beach",
            description: "Bright loft with floor-to-ceiling windows, open kitchen, and a private balcony overlooking the bay.",
            nightlyPrice: 189,
            currencyCode: "USD",
            rating: 4.92,
            reviewCount: 128,
            bedrooms: 2,
            bathrooms: 1,
            maxGuests: 4,
            amenities: ["Wi‑Fi", "Kitchen", "Washer", "Air conditioning"],
            imageURLs: [],
            imageAssetNames: assets("oceanview-loft"),
            latitude: 37.7749,
            longitude: -122.4194,
            neighborhood: "Mission District",
            city: "San Francisco",
            country: "USA",
            isAvailable: true,
            hostName: "Alex"
        ),
        Listing(
            id: "preview-2",
            title: "Redwood Cabin",
            subtitle: "Quiet forest retreat",
            description: "Cozy cabin surrounded by redwoods with a hot tub, fire pit, and hiking trails out the back door.",
            nightlyPrice: 240,
            currencyCode: "USD",
            rating: 4.88,
            reviewCount: 64,
            bedrooms: 3,
            bathrooms: 2,
            maxGuests: 6,
            amenities: ["Hot tub", "Fireplace", "Parking"],
            imageURLs: [],
            imageAssetNames: assets("redwood-cabin"),
            latitude: 37.8651,
            longitude: -122.5311,
            neighborhood: "Berkeley Hills",
            city: "Berkeley",
            country: "USA",
            isAvailable: true,
            hostName: "Jordan"
        ),
        Listing(
            id: "demo-3",
            title: "Marina Studio",
            subtitle: "Waterfront views",
            description: "Compact studio with marina views, perfect for solo travelers or couples exploring the waterfront.",
            nightlyPrice: 145,
            currencyCode: "USD",
            rating: 4.75,
            reviewCount: 41,
            bedrooms: 1,
            bathrooms: 1,
            maxGuests: 2,
            amenities: ["Wi‑Fi", "Gym"],
            imageURLs: [],
            imageAssetNames: assets("marina-studio"),
            latitude: 37.8060,
            longitude: -122.4070,
            neighborhood: "Marina",
            city: "San Francisco",
            country: "USA",
            isAvailable: true,
            hostName: "Sam"
        ),
        Listing(
            id: "demo-4",
            title: "Sonoma Vineyard Cottage",
            subtitle: "Wine country escape",
            description: "Charming cottage on a working vineyard with outdoor dining, fire pit, and valley sunsets.",
            nightlyPrice: 275,
            currencyCode: "USD",
            rating: 4.96,
            reviewCount: 89,
            bedrooms: 2,
            bathrooms: 2,
            maxGuests: 4,
            amenities: ["Pool", "Kitchen", "Free parking", "Patio"],
            imageURLs: [],
            imageAssetNames: assets("sonoma-cottage"),
            latitude: 38.2919,
            longitude: -122.4580,
            neighborhood: "Sonoma Valley",
            city: "Sonoma",
            country: "USA",
            isAvailable: true,
            hostName: "Elena"
        ),
        Listing(
            id: "demo-5",
            title: "Lake Tahoe Chalet",
            subtitle: "Alpine lakefront",
            description: "Spacious chalet with lake access, floor-to-ceiling windows, and a great room for group getaways.",
            nightlyPrice: 320,
            currencyCode: "USD",
            rating: 4.91,
            reviewCount: 112,
            bedrooms: 4,
            bathrooms: 3,
            maxGuests: 8,
            amenities: ["Lake access", "Fireplace", "Ski storage", "Hot tub"],
            imageURLs: [],
            imageAssetNames: assets("tahoe-chalet"),
            latitude: 39.0968,
            longitude: -120.0324,
            neighborhood: "Tahoe City",
            city: "Lake Tahoe",
            country: "USA",
            isAvailable: true,
            hostName: "Chris"
        ),
        Listing(
            id: "demo-6",
            title: "Pacific Heights Victorian",
            subtitle: "Classic SF elegance",
            description: "Restored Victorian with bay windows, original details, and walkable access to parks and dining.",
            nightlyPrice: 310,
            currencyCode: "USD",
            rating: 4.85,
            reviewCount: 73,
            bedrooms: 3,
            bathrooms: 2,
            maxGuests: 5,
            amenities: ["Wi‑Fi", "Workspace", "Garden", "Washer"],
            imageURLs: [],
            imageAssetNames: assets("pacific-heights"),
            latitude: 37.7920,
            longitude: -122.4370,
            neighborhood: "Pacific Heights",
            city: "San Francisco",
            country: "USA",
            isAvailable: true,
            hostName: "Riley"
        ),
    ]

    static func listing(id: String) -> Listing? {
        all.first { $0.id == id }
    }
}

extension Listing {
    func enrichedFromCatalogIfNeeded() -> Listing {
        guard let catalog = ListingCatalog.listing(id: id) else { return self }
        var updated = self
        if !catalog.imageAssetNames.isEmpty {
            updated.imageAssetNames = catalog.imageAssetNames
            updated.imageURLs = []
        } else if catalog.imageURLs.count > imageURLs.count {
            updated.imageURLs = catalog.imageURLs
        }
        if updated.description.count < catalog.description.count {
            updated.description = catalog.description
        }
        return updated
    }
}
