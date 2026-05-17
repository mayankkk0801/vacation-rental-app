import Combine
import Foundation

@MainActor
final class DiscoveryViewModel: ObservableObject {
    @Published private(set) var listings: [Listing] = []
    @Published private(set) var isLoading = true
    @Published private(set) var errorMessage: String?
    @Published var isOfflineData = false

    private let repository: ListingRepositoryProtocol
    private let analytics: AnalyticsServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(
        repository: ListingRepositoryProtocol = ListingRepository.shared,
        analytics: AnalyticsServiceProtocol = AnalyticsService.shared
    ) {
        self.repository = repository
        self.analytics = analytics
        analytics.track(.discoveryViewed)
        bind()
    }

    private func bind() {
        repository.observeListings()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    self?.isOfflineData = true
                }
                self?.isLoading = false
            } receiveValue: { [weak self] listings in
                self?.listings = listings
                self?.isLoading = false
                self?.errorMessage = nil
                let sources = listings.flatMap(\.imageSources)
                Task { await ImageLoader.shared.prefetch(sources: sources) }
            }
            .store(in: &cancellables)
    }

    func openListing(_ listing: Listing) {
        Haptics.selection()
        analytics.track(.listingOpened)
    }

    func refresh() {
        isLoading = true
    }
}
