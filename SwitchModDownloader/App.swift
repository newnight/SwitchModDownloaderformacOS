import SwiftUI

@main
struct SwitchModDownloaderApp: App {
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var settingsViewModel: SettingsViewModel

    private let searchViewModel: SearchViewModel
    private let modListViewModel: ModListViewModel
    private let modDetailViewModel: ModDetailViewModel
    private let downloadViewModel: DownloadViewModel
    private let downloadHistory: DownloadHistoryManager
    private let configurationService: ConfigurationService

    init() {
        let httpClient = HTTPClient()
        let gameBananaDataSource = GameBananaDataSource(httpClient: httpClient)
        let dataSourceManager = DataSourceManager()
        dataSourceManager.register(source: gameBananaDataSource)
        dataSourceManager.setActive(identifier: gameBananaDataSource.identifier)

        let configStore = ConfigurationStore()
        let configService = ConfigurationService(store: configStore)
        let cacheManager = CacheManager()
        let imageLoader = ImageLoader(cacheManager: cacheManager)
        let searchService = SearchService(dataSourceManager: dataSourceManager, imageLoader: imageLoader)
        let modService = ModService(dataSourceManager: dataSourceManager, imageLoader: imageLoader)
        let downloadManager = DownloadManager()
        let downloadService = DownloadService(downloadManager: downloadManager, configurationService: configService)
        let downloadHistory = DownloadHistoryManager()

        _settingsViewModel = StateObject(wrappedValue: SettingsViewModel(configurationService: configService))

        let svm = SearchViewModel(searchService: searchService)
        self.searchViewModel = svm
        self.modListViewModel = ModListViewModel(modService: modService)
        self.modDetailViewModel = ModDetailViewModel(modService: modService)
        self.downloadViewModel = DownloadViewModel(downloadService: downloadService, downloadHistory: downloadHistory, configurationService: configService)
        self.downloadHistory = downloadHistory
        self.configurationService = configService
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                searchViewModel: searchViewModel,
                modListViewModel: modListViewModel,
                modDetailViewModel: modDetailViewModel,
                downloadViewModel: downloadViewModel,
                settingsViewModel: settingsViewModel,
                downloadHistory: downloadHistory,
                configurationService: configurationService
            )
            .environment(\.locale, Locale(identifier: languageManager.currentLanguage.localeIdentifier))
            .environmentObject(languageManager)
            .onAppear {
                settingsViewModel.applyTheme(settingsViewModel.selectedTheme)
            }
        }
    }
}
