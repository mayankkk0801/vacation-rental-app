import SwiftUI
import UIKit

actor ImageLoader {
    static let shared = ImageLoader()

    private var cache = NSCache<NSString, UIImage>()
    private var inFlight: [URL: Task<UIImage?, Never>] = [:]

    func image(for source: ListingImageSource) async -> UIImage? {
        switch source {
        case .asset(let name):
            return image(assetName: name)
        case .remote(let url):
            return await image(for: url)
        }
    }

    func image(assetName: String) -> UIImage? {
        let key = "asset:\(assetName)" as NSString
        if let cached = cache.object(forKey: key) { return cached }
        guard let image = UIImage(named: assetName) else {
            #if DEBUG
            print("[ImageLoader] Missing asset:", assetName)
            #endif
            return nil
        }
        cache.setObject(image, forKey: key)
        return image
    }

    func image(for url: URL) async -> UIImage? {
        let key = url.absoluteString as NSString
        if let cached = cache.object(forKey: key) { return cached }

        if let existing = inFlight[url] {
            return await existing.value
        }

        let task = Task<UIImage?, Never> {
            guard let data = try? await URLSession.shared.data(from: url).0,
                  let image = UIImage(data: data) else { return nil }
            return image
        }
        inFlight[url] = task

        let loaded = await task.value
        inFlight[url] = nil

        if let loaded {
            cache.setObject(loaded, forKey: key)
        }
        return loaded
    }

    func prefetch(sources: [ListingImageSource]) {
        for source in sources.prefix(6) {
            Task { _ = await image(for: source) }
        }
    }
}

struct ListingImageView: View {
    let source: ListingImageSource?
    var contentMode: ContentMode = .fill

    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                Rectangle()
                    .fill(Color(.secondarySystemFill))
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
                    }
            }
        }
        .task(id: source) {
            guard let source else { return }
            image = await ImageLoader.shared.image(for: source)
        }
    }
}

/// Backward-compatible wrapper for URL-only call sites.
struct CachedAsyncImage: View {
    let url: URL?
    var contentMode: ContentMode = .fill

    var body: some View {
        ListingImageView(
            source: url.map { .remote($0) },
            contentMode: contentMode
        )
    }
}
