import Foundation
import CryptoKit

final class CacheManager {
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let maxCacheSize: Int64 = 500 * 1024 * 1024

    init() {
        let cachesDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cachesDir.appendingPathComponent("SwitchModDownloader")
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    func cachedData(for key: String) -> Data? {
        let fileURL = cacheDirectory.appendingPathComponent(key.cacheKey)
        return try? Data(contentsOf: fileURL)
    }

    func storeData(_ data: Data, for key: String) {
        let fileURL = cacheDirectory.appendingPathComponent(key.cacheKey)
        try? data.write(to: fileURL)
        trimCacheIfNeeded()
    }

    func cachedImageURL(for key: String) -> URL? {
        let fileURL = cacheDirectory.appendingPathComponent(key.cacheKey)
        return fileManager.fileExists(atPath: fileURL.path) ? fileURL : nil
    }

    func clearCache() {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    private func trimCacheIfNeeded() {
        guard let enumerator = fileManager.enumerator(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else { return }
        var totalSize: Int64 = 0
        var files: [(url: URL, size: Int64, date: Date)] = []
        for case let fileURL as URL in enumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey]),
                  let fileSize = resourceValues.fileSize,
                  let modDate = resourceValues.contentModificationDate else { continue }
            totalSize += Int64(fileSize)
            files.append((url: fileURL, size: Int64(fileSize), date: modDate))
        }
        if totalSize > maxCacheSize {
            files.sort { $0.date < $1.date }
            for file in files {
                try? fileManager.removeItem(at: file.url)
                totalSize -= file.size
                if totalSize <= maxCacheSize * 9 / 10 { break }
            }
        }
    }
}

extension String {
    var cacheKey: String {
        guard let data = self.data(using: .utf8) else { return self }
        let hash = Insecure.MD5.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
