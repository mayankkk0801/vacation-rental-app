import Foundation

@MainActor
final class DeepLinkRouter: ObservableObject {
    @Published var route: DeepLinkRoute?

    func handle(url: URL) {
        guard url.scheme == "vecationrental" else { return }

        switch url.host {
        case "listing":
            let id = url.pathComponents.dropFirst().first ?? url.queryValue(for: "id")
            if let id { route = .listing(id: id) }
        case "checkout":
            if let id = url.queryValue(for: "bookingId") {
                route = .checkout(bookingId: id)
            }
        case "search":
            route = .search
        default:
            break
        }
    }
}

enum DeepLinkRoute: Equatable {
    case listing(id: String)
    case checkout(bookingId: String)
    case search
}

private extension URL {
    func queryValue(for name: String) -> String? {
        URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first(where: { $0.name == name })?
            .value
    }
}
