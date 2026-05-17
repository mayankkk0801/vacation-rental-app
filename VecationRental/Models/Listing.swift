import CoreLocation
import Foundation

struct Listing: Identifiable, Codable, Hashable, Sendable {
    let id: String
    var title: String
    var subtitle: String
    var description: String
    var nightlyPrice: Decimal
    var currencyCode: String
    var rating: Double
    var reviewCount: Int
    var bedrooms: Int
    var bathrooms: Int
    var maxGuests: Int
    var amenities: [String]
    var imageURLs: [URL]
    var imageAssetNames: [String]
    var latitude: Double
    var longitude: Double
    var neighborhood: String
    var city: String
    var country: String
    var isAvailable: Bool
    var hostName: String

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var locationLabel: String {
        "\(neighborhood), \(city)"
    }

    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: nightlyPrice as NSDecimalNumber) ?? "$\(nightlyPrice)"
    }

    init(
        id: String,
        title: String,
        subtitle: String,
        description: String,
        nightlyPrice: Decimal,
        currencyCode: String,
        rating: Double,
        reviewCount: Int,
        bedrooms: Int,
        bathrooms: Int,
        maxGuests: Int,
        amenities: [String],
        imageURLs: [URL],
        imageAssetNames: [String] = [],
        latitude: Double,
        longitude: Double,
        neighborhood: String,
        city: String,
        country: String,
        isAvailable: Bool,
        hostName: String
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.nightlyPrice = nightlyPrice
        self.currencyCode = currencyCode
        self.rating = rating
        self.reviewCount = reviewCount
        self.bedrooms = bedrooms
        self.bathrooms = bathrooms
        self.maxGuests = maxGuests
        self.amenities = amenities
        self.imageURLs = imageURLs
        self.imageAssetNames = imageAssetNames
        self.latitude = latitude
        self.longitude = longitude
        self.neighborhood = neighborhood
        self.city = city
        self.country = country
        self.isAvailable = isAvailable
        self.hostName = hostName
    }

    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, description, nightlyPrice, currencyCode
        case rating, reviewCount, bedrooms, bathrooms, maxGuests, amenities
        case imageURLs, imageAssetNames, latitude, longitude
        case neighborhood, city, country, isAvailable, hostName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decode(String.self, forKey: .subtitle)
        description = try container.decode(String.self, forKey: .description)
        nightlyPrice = try container.decode(Decimal.self, forKey: .nightlyPrice)
        currencyCode = try container.decode(String.self, forKey: .currencyCode)
        rating = try container.decode(Double.self, forKey: .rating)
        reviewCount = try container.decode(Int.self, forKey: .reviewCount)
        bedrooms = try container.decode(Int.self, forKey: .bedrooms)
        bathrooms = try container.decode(Int.self, forKey: .bathrooms)
        maxGuests = try container.decode(Int.self, forKey: .maxGuests)
        amenities = try container.decode([String].self, forKey: .amenities)
        imageURLs = try container.decodeIfPresent([URL].self, forKey: .imageURLs) ?? []
        imageAssetNames = try container.decodeIfPresent([String].self, forKey: .imageAssetNames) ?? []
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        neighborhood = try container.decode(String.self, forKey: .neighborhood)
        city = try container.decode(String.self, forKey: .city)
        country = try container.decode(String.self, forKey: .country)
        isAvailable = try container.decode(Bool.self, forKey: .isAvailable)
        hostName = try container.decode(String.self, forKey: .hostName)
    }
}

extension Listing {
    static let preview = ListingCatalog.all[0]

    static let previews: [Listing] = Array(ListingCatalog.all.prefix(2))
}
