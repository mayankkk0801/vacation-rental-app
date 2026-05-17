@preconcurrency import Combine
import Foundation
import FirebaseCore

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

enum FirebaseAppConfigured {
    static var isReady: Bool { FirebaseApp.app() != nil }
}

@MainActor
protocol BookingRepositoryProtocol {
    func confirmBooking(_ booking: Booking) async throws
    func observeBookings() -> AnyPublisher<[Booking], Never>
}

@MainActor
final class BookingRepository: BookingRepositoryProtocol {
    static let shared = BookingRepository()

    private let cache = BookingCache.shared
    private let bookingsSubject = CurrentValueSubject<[Booking], Never>([])

    init() {
        Task { @MainActor in
            let cached = await cache.all()
            bookingsSubject.send(cached.filter { $0.status == .confirmed })
        }
    }

    func confirmBooking(_ booking: Booking) async throws {
        var confirmed = booking
        confirmed.status = .confirmed
        await cache.upsert(confirmed)
        publishFromCache()

        #if canImport(FirebaseFirestore)
        if FirebaseAppConfigured.isReady {
            try Firestore.firestore()
                .collection("bookings")
                .document(confirmed.id)
                .setData(from: confirmed)
        }
        #endif
    }

    func observeBookings() -> AnyPublisher<[Booking], Never> {
        #if canImport(FirebaseFirestore)
        if FirebaseAppConfigured.isReady {
            return firestoreBookingsPublisher()
        }
        #endif
        return bookingsSubject.eraseToAnyPublisher()
    }

    private func publishFromCache() {
        Task { @MainActor in
            let confirmed = await cache.all().filter { $0.status == .confirmed }
            bookingsSubject.send(confirmed)
        }
    }

    #if canImport(FirebaseFirestore)
    private func firestoreBookingsPublisher() -> AnyPublisher<[Booking], Never> {
        let subject = CurrentValueSubject<[Booking], Never>(bookingsSubject.value)

        let listener = Firestore.firestore()
            .collection("bookings")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self else { return }
                let remote = snapshot?.documents.compactMap { doc -> Booking? in
                    try? doc.data(as: Booking.self)
                } ?? []

                Task { @MainActor in
                    let confirmedRemote = remote.filter { $0.status == .confirmed }
                    if confirmedRemote.isEmpty {
                        let cached = await self.cache.all().filter { $0.status == .confirmed }
                        subject.send(cached)
                    } else {
                        for booking in confirmedRemote {
                            await self.cache.upsert(booking)
                        }
                        subject.send(confirmedRemote)
                    }
                }
            }

        Task { @MainActor in
            let cached = await cache.all().filter { $0.status == .confirmed }
            if !cached.isEmpty { subject.send(cached) }
        }

        return subject
            .handleEvents(receiveCancel: { listener.remove() })
            .eraseToAnyPublisher()
    }
    #endif
}
