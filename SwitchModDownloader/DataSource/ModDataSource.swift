import Foundation

struct GameSearchResult {
    let games: [Game]
    let hasMore: Bool
    let totalCount: Int
}

protocol ModDataSource: AnyObject {
    var name: String { get }
    var identifier: String { get }
    var supportedFeatures: DataSourceFeatures { get }

    func searchGames(keyword: String, page: Int) async throws -> GameSearchResult
    func searchGameByTitleId(_ titleId: String) async throws -> Game?
    func getGameDetail(gameId: Int) async throws -> Game
    func getModList(gameId: Int, page: Int, filters: ModFilters?) async throws -> ModListResult
    func getModDetail(modId: Int) async throws -> Mod
    func getFileDetail(fileId: Int) async throws -> File
    func healthCheck() async -> Bool
}
