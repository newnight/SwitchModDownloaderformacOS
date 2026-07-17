import Foundation

struct GameBananaFileDetailResponse: Codable {
    let _idRow: Int?
    let _sFile: String?
    let _nFilesize: Int64?
    let _sDownloadUrl: String?
    let _tsDateAdded: Double?
    let _aArchiveFileTree: GameBananaFileTree?

    var hasRomfs: Bool? {
        guard let tree = _aArchiveFileTree else { return nil }
        return tree.containsRomfsOrExefs
    }

    func toFile() -> File {
        let fileURL = (_sDownloadUrl.flatMap { URL(string: $0) }) ?? URL(string: "https://gamebanana.com")!
        return File(
            id: _idRow ?? 0,
            name: _sFile ?? "",
            fileID: _idRow ?? 0,
            size: _nFilesize ?? 0,
            url: fileURL,
            date: _tsDateAdded.map { Date(timeIntervalSince1970: $0) },
            romfs: hasRomfs
        )
    }
}

struct GameBananaFileTree: Codable {
    let _aChildren: [GameBananaFileTreeChild]?

    var containsRomfsOrExefs: Bool {
        guard let children = _aChildren else { return false }
        return checkChildren(children)
    }

    private func checkChildren(_ children: [GameBananaFileTreeChild]) -> Bool {
        for child in children {
            let name = (child._sName ?? "").lowercased()
            if name == "romfs" || name == "exefs" || name == "exefs_patches" {
                return true
            }
            if let subChildren = child._aChildren, checkChildren(subChildren) {
                return true
            }
        }
        return false
    }
}

struct GameBananaFileTreeChild: Codable {
    let _sName: String?
    let _aChildren: [GameBananaFileTreeChild]?
}
