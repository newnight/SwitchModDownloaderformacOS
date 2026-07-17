import Foundation

struct GameBananaSearchResponse: Codable {
    let _aMetadata: GameBananaSearchMetadata?
    let _aRecords: [GameBananaGameRecord]?

    var records: [GameBananaGameRecord] {
        _aRecords ?? []
    }
}

struct GameBananaSearchMetadata: Codable {
    let _nRecordCount: Int?
}

struct GameBananaGameRecord: Codable {
    let _idRow: Int
    let _sName: String
    let _sBannerUrl: String?
    let _aPreviewMedia: GameBananaSearchPreviewMedia?

    func toGame() -> Game {
        let banner: URL? = _sBannerUrl.flatMap { URL(string: $0) }
            ?? _aPreviewMedia?.bannerURL
        return Game(
            id: _idRow,
            title: _sName,
            gamebananaID: _idRow,
            tid: nil,
            bannerURL: banner,
            categories: nil
        )
    }
}

struct GameBananaSearchPreviewMedia: Codable {
    let _aImages: [GameBananaSearchImage]?

    var bannerURL: URL? {
        guard let images = _aImages else { return nil }
        for img in images {
            if img._sType == "banner" || img._sType == "header" {
                return img._sUrl.flatMap { URL(string: $0) }
            }
        }
        return images.first?._sUrl.flatMap { URL(string: $0) }
    }
}

struct GameBananaSearchImage: Codable {
    let _sType: String?
    let _sUrl: String?
}
