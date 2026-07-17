import Foundation
import AppKit

@MainActor
final class ImageLoader {
    private let cacheManager: CacheManager
    private var memoryCache = NSCache<NSString, NSImage>()

    init(cacheManager: CacheManager) {
        self.cacheManager = cacheManager
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 200 * 1024 * 1024
    }

    func loadImage(from url: URL) async -> NSImage? {
        let cacheKey = url.absoluteString
        if let cached = memoryCache.object(forKey: cacheKey as NSString) {
            return cached
        }
        if let cachedData = cacheManager.cachedData(for: cacheKey),
           let image = NSImage(data: cachedData) {
            memoryCache.setObject(image, forKey: cacheKey as NSString)
            return image
        }
        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 15
            request.addValue("SwitchModDownloader/1.0", forHTTPHeaderField: "User-Agent")
            let (data, _) = try await URLSession.shared.data(for: request)
            guard let image = NSImage(data: data) else { return nil }
            memoryCache.setObject(image, forKey: cacheKey as NSString)
            cacheManager.storeData(data, for: cacheKey)
            return image
        } catch {
            AppLogger.network.error("Image load failed: \(url.absoluteString) - \(error.localizedDescription)")
            return nil
        }
    }

    func clearCache() {
        memoryCache.removeAllObjects()
        cacheManager.clearCache()
    }
}
