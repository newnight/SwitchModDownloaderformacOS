import Foundation

@MainActor
final class ConfigurationService {
    private let store: ConfigurationStoreProtocol
    private var config: AppConfiguration

    init(store: ConfigurationStoreProtocol) {
        self.store = store
        self.config = store.load()
    }

    var downloadDirectory: URL {
        URL(fileURLWithPath: config.downloadDirectory)
    }

    var language: AppLanguage {
        config.language
    }

    var theme: AppTheme {
        config.theme
    }

    var defaultViewMode: DefaultViewMode {
        config.defaultViewMode
    }

    var defaultModSort: String {
        config.defaultModSort
    }

    var activeDataSource: String {
        config.activeDataSource
    }

    func updateDownloadDirectory(_ url: URL) {
        config.downloadDirectory = url.path
        store.save(config)
    }

    func updateLanguage(_ language: AppLanguage) {
        config.language = language
        store.save(config)
    }

    func updateTheme(_ theme: AppTheme) {
        config.theme = theme
        store.save(config)
    }

    func updateDefaultViewMode(_ mode: DefaultViewMode) {
        config.defaultViewMode = mode
        store.save(config)
    }

    func updateDefaultModSort(_ sort: String) {
        config.defaultModSort = sort
        store.save(config)
    }

    func getDownloadDirectory() -> URL {
        let url = URL(fileURLWithPath: config.downloadDirectory)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
}
