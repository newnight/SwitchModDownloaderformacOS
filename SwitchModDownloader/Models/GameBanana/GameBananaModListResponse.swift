import Foundation

struct GameBananaModListResponse: Codable {
    let _aRecords: [GameBananaModRecord]?
    let _nPageCount: Int?
    let _nRecordCount: Int?
    let _nPerpage: Int?
    let _aMetadata: GameBananaListMetadata?

    var records: [GameBananaModRecord] {
        _aRecords ?? []
    }

    var totalPages: Int {
        if let pageCount = _nPageCount, pageCount > 0 {
            return pageCount
        }
        let count = _aMetadata?._nRecordCount ?? _nRecordCount ?? 0
        let perPage = _aMetadata?._nPerpage ?? _nPerpage ?? 15
        guard perPage > 0, count > 0 else { return 1 }
        return (count + perPage - 1) / perPage
    }

    var totalCount: Int {
        _aMetadata?._nRecordCount ?? _nRecordCount ?? 0
    }
}

struct GameBananaListMetadata: Codable {
    let _nRecordCount: Int?
    let _nPerpage: Int?
    let _bIsComplete: Bool?
}

struct GameBananaModRecord: Codable {
    let _idRow: Int
    let _sName: String
    let _sText: String?
    let _aPreviewMedia: GameBananaPreviewMedia?
    let _aFiles: [GameBananaFileRecord]?
    let _aSubmitter: GameBananaSubmitter?
    let _idGame: Int?
    let _idCategory: Int?
    let _nDownloadCount: Int?
    let _nCommentCount: Int?
    let _nViewCount: Int?
    let _nLikeCount: Int?

    func toMod() -> Mod {
        Mod(
            id: _idRow,
            name: _sName,
            modID: _idRow,
            description: _sText,
            author: _aSubmitter?._sName,
            imageUrls: _aPreviewMedia?.imageUrls,
            files: _aFiles?.map { $0.toFile() },
            gameId: _idGame ?? 0,
            categoryId: _idCategory,
            downloadCount: _nDownloadCount,
            commentCount: _nCommentCount,
            viewCount: _nViewCount,
            likeCount: _nLikeCount
        )
    }
}

struct GameBananaSubmitter: Codable {
    let _sName: String?
}

struct GameBananaPreviewMedia: Codable {
    let _aImages: [GameBananaImage]?

    var imageUrls: [URL]? {
        _aImages?.compactMap { img -> URL? in
            img.resolvedImageUrl
        }
    }

    var bannerURL: URL? {
        guard let images = _aImages else { return nil }
        for img in images {
            if img._sType == "banner" || img._sType == "header" {
                return img.resolvedImageUrl
            }
        }
        return images.first?.resolvedImageUrl
    }
}

struct GameBananaImage: Codable {
    let _sFile: String
    let _sBaseUrl: String?
    let _sBaseUrl400: String?
    let _sType: String?

    var resolvedImageUrl: URL? {
        let file = _sFile
        let base: String
        if let base400 = _sBaseUrl400, !base400.isEmpty {
            base = base400
        } else if let b = _sBaseUrl, !b.isEmpty {
            base = b
        } else {
            return URL(string: file)
        }
        let sep = base.hasSuffix("/") || file.hasPrefix("/") ? "" : "/"
        return URL(string: base + sep + file)
    }
}

struct GameBananaFileRecord: Codable {
    let _idRow: Int
    let _sFile: String
    let _nFilesize: Int64?
    let _sDownloadUrl: String?
    let _tsDateAdded: Double?
    let _sMd5Checksum: String?

    func toFile() -> File {
        let fileURL = (_sDownloadUrl.flatMap { URL(string: $0) }) ?? URL(string: "https://gamebanana.com")!
        let fileSize = _nFilesize ?? 0
        let fileDate = _tsDateAdded.map { Date(timeIntervalSince1970: $0) }
        return File(
            id: _idRow,
            name: _sFile,
            fileID: _idRow,
            size: fileSize,
            url: fileURL,
            date: fileDate,
            romfs: nil
        )
    }
}
