import Foundation

enum AppTheme: String, Codable, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    var displayName: String {
        switch self {
        case .system: return String(localized: "Follow System")
        case .light: return String(localized: "Light")
        case .dark: return String(localized: "Dark")
        }
    }
}

enum DefaultViewMode: String, Codable, CaseIterable {
    case list = "list"
    case grid = "grid"

    var displayName: String {
        switch self {
        case .list: return String(localized: "List")
        case .grid: return String(localized: "Grid")
        }
    }
}

struct AppConfiguration: Codable {
    var downloadDirectory: String
    var language: AppLanguage
    var theme: AppTheme
    var defaultViewMode: DefaultViewMode
    var defaultModSort: String
    var activeDataSource: String
    var enableDebugLog: Bool

    enum CodingKeys: String, CodingKey {
        case downloadDirectory
        case language
        case theme
        case defaultViewMode
        case defaultModSort
        case activeDataSource
        case enableDebugLog
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        downloadDirectory = try container.decode(String.self, forKey: .downloadDirectory)
        language = try container.decode(AppLanguage.self, forKey: .language)
        theme = try container.decode(AppTheme.self, forKey: .theme)
        defaultViewMode = try container.decode(DefaultViewMode.self, forKey: .defaultViewMode)
        defaultModSort = try container.decodeIfPresent(String.self, forKey: .defaultModSort) ?? "popularity"
        activeDataSource = try container.decode(String.self, forKey: .activeDataSource)
        enableDebugLog = try container.decode(Bool.self, forKey: .enableDebugLog)
    }

    init(
        downloadDirectory: String,
        language: AppLanguage,
        theme: AppTheme,
        defaultViewMode: DefaultViewMode,
        defaultModSort: String,
        activeDataSource: String,
        enableDebugLog: Bool
    ) {
        self.downloadDirectory = downloadDirectory
        self.language = language
        self.theme = theme
        self.defaultViewMode = defaultViewMode
        self.defaultModSort = defaultModSort
        self.activeDataSource = activeDataSource
        self.enableDebugLog = enableDebugLog
    }

    static var `default`: AppConfiguration {
        let downloadsPath = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?
            .appendingPathComponent("SwitchModDownloader").path ?? "~/Downloads/SwitchModDownloader"
        return AppConfiguration(
            downloadDirectory: downloadsPath,
            language: .system,
            theme: .system,
            defaultViewMode: .list,
            defaultModSort: "popularity",
            activeDataSource: "com.gamebanana",
            enableDebugLog: false
        )
    }
}
