import Foundation

actor BookingCache {
    static let shared = BookingCache()

    private let fileURL: URL
    private var memory: [Booking] = []

    init() {
        let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        fileURL = directory.appendingPathComponent("bookings-cache.json")
        memory = (try? Self.load(from: fileURL)) ?? []
    }

    func all() -> [Booking] {
        memory.sorted { $0.createdAt > $1.createdAt }
    }

    func upsert(_ booking: Booking) {
        if let index = memory.firstIndex(where: { $0.id == booking.id }) {
            memory[index] = booking
        } else {
            memory.append(booking)
        }
        try? Self.save(memory, to: fileURL)
    }

    private static func load(from url: URL) throws -> [Booking] {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([Booking].self, from: data)
    }

    private static func save(_ bookings: [Booking], to url: URL) throws {
        let data = try JSONEncoder().encode(bookings)
        try data.write(to: url, options: .atomic)
    }
}
