import Foundation

@MainActor
final class ModService {
    private let dataSourceManager: DataSourceManager
    private let imageLoader: ImageLoader

    init(dataSourceManager: DataSourceManager, imageLoader: ImageLoader) {
        self.dataSourceManager = dataSourceManager
        self.imageLoader = imageLoader
    }

    func getModList(gameId: Int, page: Int, keyword: String? = nil, sortBy: ModFilters.SortOption? = nil) async -> Result<ModListResult, ModDownloaderError> {
        do {
            let dataSource = dataSourceManager.getActiveDataSource()
            let filters = ModFilters(keyword: keyword, sortBy: sortBy)
            let result = try await dataSource.getModList(gameId: gameId, page: page, filters: filters)
            return .success(result)
        } catch let error as ModDownloaderError {
            return .failure(error)
        } catch {
            return .failure(.networkError(underlying: error))
        }
    }

    func getModDetail(modId: Int) async -> Result<Mod, ModDownloaderError> {
        do {
            let dataSource = dataSourceManager.getActiveDataSource()
            var mod = try await dataSource.getModDetail(modId: modId)
            if var files = mod.files {
                for index in files.indices {
                    do {
                        let fileDetail = try await dataSource.getFileDetail(fileId: files[index].fileID)
                        files[index].romfs = fileDetail.romfs
                    } catch {
                        files[index].romfs = nil
                    }
                }
                mod.files = files
            }
            return .success(mod)
        } catch let error as ModDownloaderError {
            return .failure(error)
        } catch {
            return .failure(.networkError(underlying: error))
        }
    }

    func getGameDetail(gameId: Int) async -> Result<Game, ModDownloaderError> {
        do {
            let dataSource = dataSourceManager.getActiveDataSource()
            let game = try await dataSource.getGameDetail(gameId: gameId)
            return .success(game)
        } catch let error as ModDownloaderError {
            return .failure(error)
        } catch {
            return .failure(.networkError(underlying: error))
        }
    }
}
