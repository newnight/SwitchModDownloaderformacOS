import Foundation

struct SearchResult {
    let games: [Game]
    let hasMore: Bool
    let totalCount: Int
}

@MainActor
final class SearchService {
    private let dataSourceManager: DataSourceManager
    private let imageLoader: ImageLoader

    init(dataSourceManager: DataSourceManager, imageLoader: ImageLoader) {
        self.dataSourceManager = dataSourceManager
        self.imageLoader = imageLoader
    }

    func searchGames(keyword: String, page: Int = 1) async -> Result<SearchResult, ModDownloaderError> {
        guard !keyword.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .failure(.invalidConfiguration(key: "keyword"))
        }
        let isTitleId = isValidTitleId(keyword)
        do {
            let dataSource = dataSourceManager.getActiveDataSource()
            let games: [Game]
            var hasMore = false
            var totalCount = 0
            
            if isTitleId {
                if let game = try await dataSource.searchGameByTitleId(keyword) {
                    games = [game]
                    totalCount = 1
                } else {
                    games = []
                }
            } else {
                let result = try await dataSource.searchGames(keyword: keyword, page: page)
                games = result.games
                hasMore = result.hasMore
                totalCount = result.totalCount
            }
            return .success(SearchResult(games: games, hasMore: hasMore, totalCount: totalCount))
        } catch let error as ModDownloaderError {
            return .failure(error)
        } catch {
            return .failure(.networkError(underlying: error))
        }
    }

    private func isValidTitleId(_ string: String) -> Bool {
        guard string.count == 16 else { return false }
        return string.allSatisfy { $0.isHexDigit }
    }
}
