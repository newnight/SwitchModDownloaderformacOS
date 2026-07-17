import Foundation

struct File: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let fileID: Int
    let size: Int64
    let url: URL
    let date: Date?
    var romfs: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case fileID = "fileId"
        case size
        case url
        case date
        case romfs
    }

    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }

    static func == (lhs: File, rhs: File) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
