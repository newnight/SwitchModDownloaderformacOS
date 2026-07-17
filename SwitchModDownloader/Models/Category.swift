import Foundation

struct Category: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let categoryID: Int
    let iconURL: URL?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case categoryID = "categoryId"
        case iconURL = "iconUrl"
    }
}
