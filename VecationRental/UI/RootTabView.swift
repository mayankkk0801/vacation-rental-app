import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var deepLinkRouter: DeepLinkRouter

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            DiscoveryView()
                .tabItem {
                    Label(AppTab.discover.title, systemImage: AppTab.discover.systemImage)
                }
                .tag(AppTab.discover)

            SearchView()
                .tabItem {
                    Label(AppTab.search.title, systemImage: AppTab.search.systemImage)
                }
                .tag(AppTab.search)

            MapClusterView()
                .tabItem {
                    Label(AppTab.map.title, systemImage: AppTab.map.systemImage)
                }
                .tag(AppTab.map)

            TripsView()
                .tabItem {
                    Label(AppTab.trips.title, systemImage: AppTab.trips.systemImage)
                }
                .tag(AppTab.trips)
        }
        .tint(.accentColor)
        .onChange(of: deepLinkRouter.route) { _, route in
            guard let route else { return }
            switch route {
            case .listing(let id):
                appState.pendingListingID = id
                appState.selectedTab = .discover
            case .checkout:
                appState.selectedTab = .trips
            case .search:
                appState.selectedTab = .search
            }
            deepLinkRouter.route = nil
        }
    }
}
