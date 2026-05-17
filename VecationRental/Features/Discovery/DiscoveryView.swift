import SwiftUI

struct DiscoveryView: View {
    @StateObject private var viewModel = DiscoveryViewModel()
    @EnvironmentObject private var appState: AppState
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if viewModel.isLoading && viewModel.listings.isEmpty {
                    ProgressView("Finding stays…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if viewModel.isOfflineData || appState.isOffline {
                                OfflineBanner()
                            }
                            ForEach(viewModel.listings) { listing in
                                Button {
                                    navigationPath.append(listing)
                                } label: {
                                    ListingCardView(listing: listing)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Listing.self) { listing in
                ListingDetailView(listing: listing)
                    .environmentObject(appState)
            }
            .refreshable {
                viewModel.refresh()
            }
            .onChange(of: appState.selectedTab) { _, tab in
                if tab != .discover {
                    navigationPath = NavigationPath()
                }
            }
        }
    }
}

struct OfflineBanner: View {
    var body: some View {
        Label("Showing cached listings", systemImage: "wifi.slash")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Offline mode. Showing cached listings.")
    }
}

#Preview {
    RootTabView()
        .environmentObject(AppState())
        .environmentObject(DeepLinkRouter())
}
