import Foundation

struct ModListResult {
    let mods: [Mod]
    let currentPage: Int
    let totalPages: Int
    let perPage: Int
    let totalCount: Int

    var hasNextPage: Bool {
        currentPage < totalPages
    }
}
