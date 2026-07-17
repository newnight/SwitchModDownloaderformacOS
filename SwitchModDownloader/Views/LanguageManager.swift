import SwiftUI

class LanguageManager: ObservableObject {
    @Published var currentLanguage: AppLanguage = .system

    init() {
        let store = ConfigurationStore()
        self.currentLanguage = store.load().language
    }

    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
    }
}
