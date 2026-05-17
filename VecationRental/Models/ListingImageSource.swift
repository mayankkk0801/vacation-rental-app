import Foundation

enum ListingImageSource: Hashable, Sendable {
    case asset(String)
    case remote(URL)
}

extension Listing {
    var imageSources: [ListingImageSource] {
        if !imageAssetNames.isEmpty {
            return imageAssetNames.map { .asset($0) }
        }
        return imageURLs.map { .remote($0) }
    }

    var primaryImageSource: ListingImageSource? {
        imageSources.first
    }
}
