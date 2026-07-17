import Foundation

struct DataSourceFeatures: OptionSet {
    let rawValue: Int

    static let gameSearch = DataSourceFeatures(rawValue: 1 << 0)
    static let titleIdSearch = DataSourceFeatures(rawValue: 1 << 1)
    static let categoryFilter = DataSourceFeatures(rawValue: 1 << 2)
    static let keywordSearch = DataSourceFeatures(rawValue: 1 << 3)
    static let statistics = DataSourceFeatures(rawValue: 1 << 4)
    static let fileTree = DataSourceFeatures(rawValue: 1 << 5)
}
