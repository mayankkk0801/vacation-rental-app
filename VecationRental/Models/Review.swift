import Foundation

struct Review: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let listingID: String
    let authorName: String
    let rating: Int
    let body: String
    let createdAt: Date
}
