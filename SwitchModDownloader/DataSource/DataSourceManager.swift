import Foundation

@MainActor
final class DataSourceManager {
    private var dataSources: [String: ModDataSource] = [:]
    private var activeIdentifier: String = "com.gamebanana"

    func register(source: ModDataSource) {
        dataSources[source.identifier] = source
    }

    func setActive(identifier: String) {
        activeIdentifier = identifier
    }

    func getActiveDataSource() -> ModDataSource {
        if let source = dataSources[activeIdentifier] {
            return source
        }
        if let fallback = dataSources.values.first {
            AppLogger.dataSource.warning("Active data source '\(self.activeIdentifier)' not found, using fallback: \(fallback.name)")
            return fallback
        }
        fatalError("No data sources registered")
    }

    var activeFeatures: DataSourceFeatures {
        getActiveDataSource().supportedFeatures
    }
}
