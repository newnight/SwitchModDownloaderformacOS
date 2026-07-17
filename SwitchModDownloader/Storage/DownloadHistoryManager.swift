import Foundation

@MainActor
final class DownloadHistoryManager: ObservableObject {
    private let defaults = UserDefaults.standard
    private let fileIdsKey = "downloadedFileIds"
    private let historyKey = "downloadHistory"
    @Published private(set) var downloadedFileIds: Set<Int>
    @Published private(set) var history: [DownloadHistoryItem]

    init() {
        if let data = defaults.array(forKey: fileIdsKey) as? [Int] {
            downloadedFileIds = Set(data)
        } else {
            downloadedFileIds = []
        }
        
        if let data = defaults.data(forKey: historyKey),
           let items = try? JSONDecoder().decode([DownloadHistoryItem].self, from: data) {
            history = items
        } else {
            history = []
        }
    }

    func markDownloaded(fileId: Int) {
        downloadedFileIds.insert(fileId)
        persistFileIds()
    }
    
    func addHistoryItem(_ item: DownloadHistoryItem) {
        downloadedFileIds.insert(item.fileId)
        history.insert(item, at: 0)
        persistFileIds()
        persistHistory()
    }

    func isDownloaded(fileId: Int) -> Bool {
        downloadedFileIds.contains(fileId)
    }
    
    func historyByGame() -> [Int: [DownloadHistoryItem]] {
        Dictionary(grouping: history, by: { $0.gameId })
    }
    
    func clearHistory() {
        history = []
        persistHistory()
    }

    private func persistFileIds() {
        defaults.set(Array(downloadedFileIds), forKey: fileIdsKey)
    }
    
    private func persistHistory() {
        if let data = try? JSONEncoder().encode(history) {
            defaults.set(data, forKey: historyKey)
        }
    }
}
