import Foundation

protocol ConfigurationStoreProtocol {
    func load() -> AppConfiguration
    func save(_ config: AppConfiguration)
    func reset()
}

final class ConfigurationStore: ConfigurationStoreProtocol {
    private let defaults = UserDefaults.standard
    private let key = "appConfiguration"

    func load() -> AppConfiguration {
        guard let data = defaults.data(forKey: key) else {
            return .default
        }
        do {
            return try JSONDecoder().decode(AppConfiguration.self, from: data)
        } catch {
            AppLogger.storage.warning("Configuration load failed, using defaults: \(error.localizedDescription)")
            return .default
        }
    }

    func save(_ config: AppConfiguration) {
        do {
            let data = try JSONEncoder().encode(config)
            defaults.set(data, forKey: key)
        } catch {
            AppLogger.storage.error("Configuration save failed: \(error.localizedDescription)")
        }
    }

    func reset() {
        defaults.removeObject(forKey: key)
    }
}
