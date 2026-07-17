import Foundation

struct DownloadHistoryItem: Codable, Identifiable {
    let id: UUID
    let fileId: Int
    let fileName: String
    let modName: String
    let gameName: String
    let gameId: Int
    let downloadDate: Date
    let fileSize: Int64
    let gameBannerUrl: URL?
    let modImageUrls: [URL]?
    
    init(fileId: Int, fileName: String, modName: String, gameName: String, gameId: Int, fileSize: Int64, gameBannerUrl: URL? = nil, modImageUrls: [URL]? = nil) {
        self.id = UUID()
        self.fileId = fileId
        self.fileName = fileName
        self.modName = modName
        self.gameName = gameName
        self.gameId = gameId
        self.downloadDate = Date()
        self.fileSize = fileSize
        self.gameBannerUrl = gameBannerUrl
        self.modImageUrls = modImageUrls
    }
}
