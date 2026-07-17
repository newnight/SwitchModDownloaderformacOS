import Foundation
import AppKit

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var downloadDirectory: String = ""
    @Published var selectedLanguage: AppLanguage = .system
    @Published var selectedTheme: AppTheme = .system
    @Published var selectedDefaultViewMode: DefaultViewMode = .list
    @Published var selectedDefaultModSort: ModFilters.SortOption = .popularity
    @Published var errorMessage: String?

    private let configurationService: ConfigurationService

    init(configurationService: ConfigurationService) {
        self.configurationService = configurationService
        self.downloadDirectory = configurationService.downloadDirectory.path
        self.selectedLanguage = configurationService.language
        self.selectedTheme = configurationService.theme
        self.selectedDefaultViewMode = configurationService.defaultViewMode
        self.selectedDefaultModSort = ModFilters.SortOption(rawValue: configurationService.defaultModSort) ?? .popularity
    }

    func updateDownloadDirectory(_ url: URL) {
        let fm = FileManager.default
        if !fm.isWritableFile(atPath: url.path) {
            errorMessage = String(localized: "Selected path has no write permission")
            return
        }
        configurationService.updateDownloadDirectory(url)
        downloadDirectory = url.path
        errorMessage = nil
    }

    func updateLanguage(_ language: AppLanguage) {
        configurationService.updateLanguage(language)
        selectedLanguage = language
    }

    func updateTheme(_ theme: AppTheme) {
        configurationService.updateTheme(theme)
        selectedTheme = theme
        applyTheme(theme)
    }

    func updateDefaultViewMode(_ mode: DefaultViewMode) {
        configurationService.updateDefaultViewMode(mode)
        selectedDefaultViewMode = mode
    }

    func updateDefaultModSort(_ sort: ModFilters.SortOption) {
        configurationService.updateDefaultModSort(sort.rawValue)
        selectedDefaultModSort = sort
    }

    func selectDownloadDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = String(localized: "Select")

        if panel.runModal() == .OK, let url = panel.urls.first {
            updateDownloadDirectory(url)
        }
    }

    func applyTheme(_ theme: AppTheme) {
        switch theme {
        case .system:
            NSApp.appearance = nil
        case .light:
            NSApp.appearance = NSAppearance(named: .aqua)
        case .dark:
            NSApp.appearance = NSAppearance(named: .darkAqua)
        }
    }
}
