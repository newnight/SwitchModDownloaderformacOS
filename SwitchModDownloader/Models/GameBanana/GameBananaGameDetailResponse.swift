import Foundation

struct GameBananaGameDetailResponse: Codable {
    let _sName: String?
    let _idRow: Int?
    let _aPreviewMedia: GameBananaPreviewMedia?
    let _aModRootCategories: [GameBananaCategoryRecord]?
    let _sBannerUrl: String?

    func toGame() -> Game {
        // 优先使用 _sBannerUrl，否则使用 _aPreviewMedia
        let banner: URL?
        if let bannerStr = _sBannerUrl {
            banner = URL(string: bannerStr)
        } else {
            banner = _aPreviewMedia?.bannerURL
        }
        
        return Game(
            id: _idRow ?? 0,
            title: _sName ?? "",
            gamebananaID: _idRow ?? 0,
            tid: nil,
            bannerURL: banner,
            categories: _aModRootCategories?.map { $0.toCategory() }
        )
    }
}

struct GameBananaCategoryRecord: Codable {
    let _sName: String?
    let _idRow: Int?

    func toCategory() -> Category {
        Category(
            id: _idRow ?? 0,
            name: _sName ?? "",
            categoryID: _idRow ?? 0,
            iconURL: nil
        )
    }
}
