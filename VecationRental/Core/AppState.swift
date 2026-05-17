import Combine
import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var selectedTab: AppTab = .discover
    @Published var pendingListingID: String?
    @Published var isOffline = false

    private var cancellables = Set<AnyCancellable>()

    init(networkMonitor: NetworkMonitor = .shared) {
        networkMonitor.$isConnected
            .receive(on: DispatchQueue.main)
            .map { !$0 }
            .assign(to: &$isOffline)
    }
}

enum AppTab: String, CaseIterable, Identifiable, Hashable {
    case discover
    case search
    case map
    case trips

    var id: String { rawValue }

    var title: String {
        switch self {
        case .discover: return "Discover"
        case .search: return "Search"
        case .map: return "Map"
        case .trips: return "Trips"
        }
    }

    var systemImage: String {
        switch self {
        case .discover: return "house.fill"
        case .search: return "magnifyingglass"
        case .map: return "map.fill"
        case .trips: return "suitcase.fill"
        }
    }
}
