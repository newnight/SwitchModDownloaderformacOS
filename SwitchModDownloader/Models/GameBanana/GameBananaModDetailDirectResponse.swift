import Foundation

struct GameBananaModDetailDirectResponse: Codable {
    let _idRow: Int?
    let _sName: String?
    let _sText: String?
    let _aSubmitter: GameBananaSubmitter?
    let _aPreviewMedia: GameBananaPreviewMedia?
    let _aFiles: [GameBananaFileRecord]?
    let _nDownloadCount: Int?
    let _nViewCount: Int?
    let _nLikeCount: Int?

    func toMod() -> Mod {
        let modId = _idRow ?? 0
        return Mod(
            id: modId,
            name: _sName ?? "",
            modID: modId,
            description: _sText,
            author: _aSubmitter?._sName,
            imageUrls: _aPreviewMedia?.imageUrls,
            files: _aFiles?.map { $0.toFile() },
            gameId: 0,
            categoryId: nil,
            downloadCount: _nDownloadCount,
            commentCount: nil,
            viewCount: _nViewCount,
            likeCount: _nLikeCount
        )
    }
}
