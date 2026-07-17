import Foundation

struct Game: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let gamebananaID: Int
    let tid: String?
    let bannerURL: URL?
    var categories: [Category]?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case gamebananaID = "gamebananaId"
        case tid = "titleId"
        case bannerURL = "bannerUrl"
        case categories
    }
}
