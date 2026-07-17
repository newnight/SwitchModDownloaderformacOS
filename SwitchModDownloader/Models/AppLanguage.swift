import Foundation

enum AppLanguage: String, Codable, CaseIterable {
    case system = "system"
    case chinese = "zh-CN"
    case english = "en"

    var displayName: String {
        switch self {
        case .system: return String(localized: "Follow System")
        case .chinese: return "中文"
        case .english: return "English"
        }
    }

    var localeIdentifier: String {
        switch self {
        case .system: return Locale.current.identifier
        case .chinese: return "zh_CN"
        case .english: return "en_US"
        }
    }
}
