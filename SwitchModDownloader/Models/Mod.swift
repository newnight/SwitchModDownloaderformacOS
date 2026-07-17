import Foundation

struct Mod: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let modID: Int
    let description: String?
    let author: String?
    let imageUrls: [URL]?
    var files: [File]?
    let gameId: Int
    let categoryId: Int?
    let downloadCount: Int?
    let commentCount: Int?
    let viewCount: Int?
    let likeCount: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case modID = "modId"
        case description
        case author
        case imageUrls
        case files
        case gameId
        case categoryId
        case downloadCount = "downloadCount"
        case commentCount = "commentCount"
        case viewCount = "viewCount"
        case likeCount = "likeCount"
    }

    static func == (lhs: Mod, rhs: Mod) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
