import Foundation

struct ModFilters {
    var keyword: String?
    var sortBy: SortOption?

    enum SortOption: String, CaseIterable {
        case bestMatch = "best_match"
        case popularity = "popularity"
        case date = "date"
        case update = "update"

        var displayName: String {
            switch self {
            case .bestMatch: return String(localized: "Relevance")
            case .popularity: return String(localized: "Popularity")
            case .date: return String(localized: "Newest")
            case .update: return String(localized: "Recently Updated")
            }
        }
    }
}
