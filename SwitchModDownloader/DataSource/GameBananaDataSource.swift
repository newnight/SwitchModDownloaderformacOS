import Foundation

final class GameBananaDataSource: ModDataSource, @unchecked Sendable {
    let name = "GameBanana"
    let identifier = "com.gamebanana"

    let supportedFeatures: DataSourceFeatures = [
        .gameSearch, .titleIdSearch, .categoryFilter, .keywordSearch, .statistics, .fileTree
    ]

    private let httpClient: HTTPClientProtocol
    private let baseURL = URL(string: "https://gamebanana.com/apiv11")!

    init(httpClient: HTTPClientProtocol) {
        self.httpClient = httpClient
    }

    func searchGames(keyword: String, page: Int = 1) async throws -> GameSearchResult {
        let endpoint = baseURL.appendingPathComponent("Util/Game/NameMatch")
        let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? keyword
        let params: [String: String] = [
            "_sName": encodedKeyword,
            "_nPage": "\(page)",
            "_nPerpage": "50"
        ]
        
        let response: GameBananaSearchResponse = try await httpClient.get(url: endpoint, params: params)
        let games = response.records.map { $0.toGame() }.filter { $0.gamebananaID != 6384 }
        let totalCount = response._aMetadata?._nRecordCount ?? games.count
        let hasMore = games.count >= 50 && (totalCount > page * 50)
        
        return GameSearchResult(games: games, hasMore: hasMore, totalCount: totalCount)
    }

    func searchGameByTitleId(_ titleId: String) async throws -> Game? {
        let endpoint = baseURL.appendingPathComponent("Util/Game/NameMatch")
        let params: [String: String] = ["_sName": titleId]
        let response: GameBananaSearchResponse = try await httpClient.get(url: endpoint, params: params)
        let switchGames = response.records.filter { $0._sName.localizedCaseInsensitiveContains("Switch") }
        return (switchGames.isEmpty ? response.records.first : switchGames.first)?.toGame()
    }

    func getGameDetail(gameId: Int) async throws -> Game {
        let endpoint = baseURL.appendingPathComponent("Game/\(gameId)")
        // 不使用 _csvProperties，获取所有字段
        let response: GameBananaGameDetailResponse = try await httpClient.get(url: endpoint, params: nil)
        return response.toGame()
    }

    func getModList(gameId: Int, page: Int, filters: ModFilters?) async throws -> ModListResult {
        let sortParam = filters?.sortBy?.rawValue ?? "popularity"
        let endpoint = baseURL.appendingPathComponent("Util/Search/Results")
        var params: [String: String] = [
            "_sModelName": "Mod",
            "_idGameRow": "\(gameId)",
            "_sOrder": sortParam,
            "_nPage": "\(page)",
            "_nPerpage": "50",
            "_csvFields": "name,description,article,attribs,studio,owner,credits"
        ]
        if let keyword = filters?.keyword, !keyword.isEmpty {
            params["_sSearchString"] = keyword
        } else {
            params["_sSearchString"] = "mod"
        }
        let response: GameBananaModListResponse = try await httpClient.get(url: endpoint, params: params)
        return ModListResult(
            mods: response.records.map { $0.toMod() },
            currentPage: page,
            totalPages: response.totalPages,
            perPage: 50,
            totalCount: response.totalCount
        )
    }

    func getModDetail(modId: Int) async throws -> Mod {
        let endpoint = baseURL.appendingPathComponent("Mod/\(modId)")
        let params: [String: String] = [
            "_csvProperties": "_idRow,_sName,_sText,_aFiles,_aPreviewMedia,_nDownloadCount,_nLikeCount,_nViewCount,_aSubmitter"
        ]
        let response: GameBananaModDetailDirectResponse = try await httpClient.get(url: endpoint, params: params)
        let mod = response.toMod()
        guard mod.id != 0 else {
            throw ModDownloaderError.modNotFound(modId: modId)
        }
        return mod
    }

    func getFileDetail(fileId: Int) async throws -> File {
        let endpoint = baseURL.appendingPathComponent("File/\(fileId)")
        let response: GameBananaFileDetailResponse = try await httpClient.get(url: endpoint, params: nil)
        return response.toFile()
    }

    func healthCheck() async -> Bool {
        do {
            let endpoint = baseURL.appendingPathComponent("Util/Game/NameMatch")
            let params: [String: String] = ["_sName": "test"]
            _ = try await httpClient.get(url: endpoint, params: params) as GameBananaSearchResponse
            return true
        } catch {
            return false
        }
    }
}
