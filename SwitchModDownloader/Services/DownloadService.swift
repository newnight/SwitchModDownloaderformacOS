import Foundation

@MainActor
final class DownloadService: ObservableObject {
    @Published var activeDownloads: [String: DownloadProgress] = [:]
    @Published var completedDownloads: Set<String> = []

    private let downloadManager: DownloadManagerProtocol
    private let configurationService: ConfigurationService

    init(downloadManager: DownloadManagerProtocol, configurationService: ConfigurationService) {
        self.downloadManager = downloadManager
        self.configurationService = configurationService
    }

    func startDownload(file: File, gameName: String? = nil, modName: String? = nil, targetPath: URL? = nil) -> Result<String, ModDownloaderError> {
        let baseDir = targetPath ?? configurationService.getDownloadDirectory()
        
        let downloadDir: URL
        if let gameName = gameName, !gameName.isEmpty {
            let sanitizedGameName = gameName
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: ":", with: "_")
                .replacingOccurrences(of: "\\", with: "_")
            let gameDir = baseDir.appendingPathComponent(sanitizedGameName)
            
            if let modName = modName, !modName.isEmpty {
                let sanitizedModName = modName
                    .replacingOccurrences(of: "/", with: "_")
                    .replacingOccurrences(of: ":", with: "_")
                    .replacingOccurrences(of: "\\", with: "_")
                downloadDir = gameDir.appendingPathComponent(sanitizedModName)
            } else {
                downloadDir = gameDir
            }
        } else {
            downloadDir = baseDir
        }
        
        do {
            try FileManager.default.createDirectory(at: downloadDir, withIntermediateDirectories: true)
        } catch {
            AppLogger.storage.error("Failed to create download directory: \(downloadDir.path), error: \(error.localizedDescription)")
            return .failure(.downloadPathNotWritable(path: downloadDir.path))
        }
        
        let destination = downloadDir.appendingPathComponent(file.name)

        guard hasEnoughDiskSpace(fileSize: file.size, at: downloadDir) else {
            let available = availableDiskSpace(at: downloadDir)
            return .failure(.diskSpaceInsufficient(required: file.size, available: available))
        }

        guard isWritable(path: downloadDir) else {
            return .failure(.downloadPathNotWritable(path: downloadDir.path))
        }

        guard let dm = downloadManager as? DownloadManager else {
            return .failure(.downloadFailed(underlying: NSError(domain: "DownloadManager", code: -1)))
        }

        let resumeKey = "resume_\(file.fileID)"
        let resumeData = UserDefaults.standard.data(forKey: resumeKey)

        let taskInfo: DownloadTaskInfo
        if let resumeData = resumeData {
            taskInfo = dm.resumeDownload(url: file.url, to: destination, resumeData: resumeData)
        } else {
            taskInfo = dm.startDownload(url: file.url, to: destination)
        }

        dm.onProgress(taskId: taskInfo.id) { [weak self] progress in
            Task { @MainActor in
                self?.activeDownloads[taskInfo.id] = progress
            }
        }

        dm.onCompletion(taskId: taskInfo.id) { [weak self] result in
            Task { @MainActor in
                self?.activeDownloads.removeValue(forKey: taskInfo.id)
                UserDefaults.standard.removeObject(forKey: resumeKey)
                if case .success = result {
                    self?.completedDownloads.insert(taskInfo.id)
                }
            }
        }

        return .success(taskInfo.id)
    }

    func pauseDownload(taskId: String, fileId: Int) {
        guard let dm = downloadManager as? DownloadManager else { return }
        if let resumeData = dm.pauseDownload(taskId: taskId) {
            let resumeKey = "resume_\(fileId)"
            UserDefaults.standard.set(resumeData, forKey: resumeKey)
        }
        activeDownloads.removeValue(forKey: taskId)
    }

    func cancelDownload(taskId: String) {
        guard let dm = downloadManager as? DownloadManager else { return }
        _ = dm.cancelDownload(taskId: taskId)
        activeDownloads.removeValue(forKey: taskId)
    }

    func hasResumeData(for fileId: Int) -> Bool {
        let resumeKey = "resume_\(fileId)"
        return UserDefaults.standard.data(forKey: resumeKey) != nil
    }

    private func hasEnoughDiskSpace(fileSize: Int64, at directory: URL) -> Bool {
        let available = availableDiskSpace(at: directory)
        return available > fileSize + 100 * 1024 * 1024
    }

    private func availableDiskSpace(at url: URL) -> Int64 {
        let values = try? url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
        return Int64(values?.volumeAvailableCapacityForImportantUsage ?? 0)
    }

    private func isWritable(path: URL) -> Bool {
        FileManager.default.isWritableFile(atPath: path.path)
    }
}
