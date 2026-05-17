import Foundation

protocol AnalyticsServiceProtocol: Sendable {
    func track(_ event: AnalyticsEvent)
    func experimentVariant(for flag: ExperimentFlag) -> String
}

enum AnalyticsEvent: String, Sendable {
    case discoveryViewed = "discovery_viewed"
    case listingOpened = "listing_opened"
    case searchSubmitted = "search_submitted"
    case filterApplied = "filter_applied"
    case mapClusterTapped = "map_cluster_tapped"
    case checkoutStarted = "checkout_started"
    case checkoutCompleted = "checkout_completed"
    case bookingFailed = "booking_failed"
}

enum ExperimentFlag: String, Sendable {
    case checkoutCTA = "checkout_cta_copy"
    case listingCardLayout = "listing_card_layout"
}

final class AnalyticsService: AnalyticsServiceProtocol {
    static let shared = AnalyticsService()

    func track(_ event: AnalyticsEvent) {
        #if DEBUG
        print("[Analytics]", event.rawValue)
        #endif
        // Wire to Firebase Analytics, Amplitude, etc.
    }

    func experimentVariant(for flag: ExperimentFlag) -> String {
        switch flag {
        case .checkoutCTA:
            return Bool.random() ? "reserve_now" : "book_stay"
        case .listingCardLayout:
            return Bool.random() ? "compact" : "hero"
        }
    }
}
