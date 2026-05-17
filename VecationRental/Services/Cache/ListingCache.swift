import Foundation

actor ListingCache {
    static let shared = ListingCache()

    private let fileURL: URL
    private var memory: [Listing] = []

    init() {
        let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        fileURL = directory.appendingPathComponent("listings-cache.json")
        memory = (try? Self.load(from: fileURL)) ?? []
    }

    func all() -> [Listing] { memory }

    func replace(_ listings: [Listing]) {
        memory = listings
        try? Self.save(listings, to: fileURL)
    }

    func upsert(_ listing: Listing) {
        if let index = memory.firstIndex(where: { $0.id == listing.id }) {
            memory[index] = listing
        } else {
            memory.append(listing)
        }
        try? Self.save(memory, to: fileURL)
    }

    private static func load(from url: URL) throws -> [Listing] {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([Listing].self, from: data)
    }

    private static func save(_ listings: [Listing], to url: URL) throws {
        let data = try JSONEncoder().encode(listings)
        try data.write(to: url, options: .atomic)
    }
}
