import Combine
import Foundation
import FirebaseCore

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

protocol ListingRepositoryProtocol: Sendable {
    func observeListings() -> AnyPublisher<[Listing], Error>
    func fetchListing(id: String) async throws -> Listing?
    func observeReviews(listingID: String) -> AnyPublisher<[Review], Error>
    func updateAvailability(listingID: String, isAvailable: Bool) async throws
}

final class ListingRepository: ListingRepositoryProtocol {
    static let shared = ListingRepository()

    private let cache = ListingCache.shared
    private let demoData = DemoListingProvider()

    func observeListings() -> AnyPublisher<[Listing], Error> {
        #if canImport(FirebaseFirestore)
        if FirebaseApp.app() != nil {
            return firestoreListingsPublisher()
        }
        #endif
        return demoListingsPublisher()
    }

    func fetchListing(id: String) async throws -> Listing? {
        if let cached = await cache.all().first(where: { $0.id == id }) {
            return cached
        }
        return ListingCatalog.listing(id: id) ?? demoData.listings.first { $0.id == id }
    }

    func observeReviews(listingID: String) -> AnyPublisher<[Review], Error> {
        Just(demoData.reviews(for: listingID))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func updateAvailability(listingID: String, isAvailable: Bool) async throws {
        var listings = await cache.all()
        guard let index = listings.firstIndex(where: { $0.id == listingID }) else { return }
        listings[index].isAvailable = isAvailable
        await cache.replace(listings)
    }

    private func demoListingsPublisher() -> AnyPublisher<[Listing], Error> {
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .prepend(Date())
            .map { _ in self.demoData.listings }
            .handleEvents(receiveOutput: { listings in
                Task { await self.cache.replace(listings) }
            })
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    #if canImport(FirebaseFirestore)
    private func firestoreListingsPublisher() -> AnyPublisher<[Listing], Error> {
        let subject = PassthroughSubject<[Listing], Error>()
        let listener = Firestore.firestore()
            .collection("listings")
            .addSnapshotListener { snapshot, error in
                if let error {
                    Task {
                        let cached = await self.cache.all()
                        if !cached.isEmpty {
                            subject.send(cached)
                        } else {
                            subject.send(completion: .failure(error))
                        }
                    }
                    return
                }
                let remote = snapshot?.documents.compactMap { doc -> Listing? in
                    try? doc.data(as: Listing.self)
                } ?? []
                let base = remote.isEmpty ? self.demoData.listings : remote
                let listings = base.map { $0.enrichedFromCatalogIfNeeded() }
                    .map { listing in
                        guard listing.imageSources.isEmpty,
                              let catalog = ListingCatalog.listing(id: listing.id) else { return listing }
                        return catalog
                    }
                Task {
                    await self.cache.replace(listings)
                    subject.send(listings)
                }
            }
        return subject
            .handleEvents(receiveCancel: { listener.remove() })
            .eraseToAnyPublisher()
    }
    #endif
}

private struct DemoListingProvider {
    let listings: [Listing] = ListingCatalog.all

    func reviews(for listingID: String) -> [Review] {
        [
            Review(
                id: "r1",
                listingID: listingID,
                authorName: "Taylor",
                rating: 5,
                body: "Spotless and exactly as described. Would book again.",
                createdAt: Date().addingTimeInterval(-86400 * 12)
            ),
            Review(
                id: "r2",
                listingID: listingID,
                authorName: "Morgan",
                rating: 4,
                body: "Great location. Check-in was smooth.",
                createdAt: Date().addingTimeInterval(-86400 * 30)
            )
        ]
    }
}
