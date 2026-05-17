import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject private var appState: AppState
    @State private var showFilters = false
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                searchBar
                filterChips
                Divider()
                resultsBody
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showFilters) {
                FilterSheetView(filters: $viewModel.filters) {
                    viewModel.submitSearch()
                    showFilters = false
                }
            }
            .navigationDestination(for: Listing.self) { listing in
                ListingDetailView(listing: listing)
                    .environmentObject(appState)
            }
            .onChange(of: appState.selectedTab) { _, tab in
                if tab != .search {
                    navigationPath = NavigationPath()
                }
            }
        }
    }

    @ViewBuilder
    private var resultsBody: some View {
        if viewModel.results.isEmpty {
            ContentUnavailableView(
                "No stays found",
                systemImage: "building.2.crop.circle",
                description: Text("Try adjusting filters or search terms.")
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List(viewModel.results) { listing in
                NavigationLink(value: listing) {
                    ListingRowView(listing: listing)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Destination, neighborhood…", text: $viewModel.filters.query)
                .textInputAutocapitalization(.words)
                .submitLabel(.search)
                .onSubmit { viewModel.submitSearch() }
                .accessibilityLabel("Search destination or neighborhood")
            Button {
                showFilters = true
                Haptics.selection()
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .overlay(alignment: .topTrailing) {
                        if viewModel.filters.activeFilterCount > 0 {
                            Text("\(viewModel.filters.activeFilterCount)")
                                .font(.caption2.bold())
                                .padding(4)
                                .background(Color.accentColor, in: Circle())
                                .foregroundStyle(.white)
                                .offset(x: 6, y: -6)
                        }
                    }
            }
            .accessibilityLabel("Filters, \(viewModel.filters.activeFilterCount) active")
        }
        .padding(12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(SearchFilters.SortOption.allCases) { option in
                    FilterChip(
                        title: option.label,
                        isSelected: viewModel.filters.sort == option
                    ) {
                        viewModel.filters.sort = option
                        viewModel.submitSearch()
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
