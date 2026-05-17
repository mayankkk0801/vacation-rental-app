import Combine
import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var filters = SearchFilters()
    @Published private(set) var results: [Listing] = []
    @Published private(set) var isSearching = false

    private let repository: ListingRepositoryProtocol
    private let analytics: AnalyticsServiceProtocol
    private var allListings: [Listing] = []
    private var cancellables = Set<AnyCancellable>()

    init(
        repository: ListingRepositoryProtocol = ListingRepository.shared,
        analytics: AnalyticsServiceProtocol = AnalyticsService.shared
    ) {
        self.repository = repository
        self.analytics = analytics
        bind()
        bindFilterPipeline()
    }

    private func bind() {
        repository.observeListings()
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { [weak self] listings in
                self?.allListings = listings
                self?.applyFilters()
            }
            .store(in: &cancellables)
    }

    private func bindFilterPipeline() {
        $filters
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
    }

    func submitSearch() {
        isSearching = true
        analytics.track(.searchSubmitted)
        if filters.activeFilterCount > 0 {
            analytics.track(.filterApplied)
        }
        applyFilters()
        isSearching = false
        Haptics.lightImpact()
    }

    func resetFilters() {
        filters = SearchFilters()
        Haptics.selection()
    }

    private func applyFilters() {
        let filtered = allListings.filter { filters.matches($0) }
        results = filters.sorted(filtered)
    }
}
