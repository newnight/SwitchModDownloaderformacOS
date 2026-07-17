import Foundation
import AppKit

struct FileDownloadState {
    var taskId: String?
    var progress: DownloadProgress?
    var isDownloading: Bool = false
    var isPaused: Bool = false
    var isCompleted: Bool = false
}

struct PendingDownloadInfo {
    let fileName: String
    let modName: String
    let gameName: String
    let gameId: Int
    let fileSize: Int64
    let gameBannerUrl: URL?
    let modImageUrls: [URL]?
    let modDescription: String?
    let modAuthor: String?
}

@MainActor
class DownloadViewModel: ObservableObject {
    @Published var fileStates: [Int: FileDownloadState] = [:]
    @Published var recentCompletedFileId: Int?
    
    private var pendingInfo: [Int: PendingDownloadInfo] = [:]

    private let downloadService: DownloadService
    private let downloadHistory: DownloadHistoryManager
    private let configurationService: ConfigurationService
    private var progressTimers: [String: Timer] = [:]

    init(downloadService: DownloadService, downloadHistory: DownloadHistoryManager, configurationService: ConfigurationService) {
        self.downloadService = downloadService
        self.downloadHistory = downloadHistory
        self.configurationService = configurationService
    }

    func startDownload(file: File, modName: String = "", gameName: String = "", gameId: Int = 0, gameBannerUrl: URL? = nil, modImageUrls: [URL]? = nil, modDescription: String? = nil, modAuthor: String? = nil) {
        let fileId = file.fileID
        fileStates[fileId] = FileDownloadState(isDownloading: true)
        pendingInfo[fileId] = PendingDownloadInfo(
            fileName: file.name,
            modName: modName,
            gameName: gameName,
            gameId: gameId,
            fileSize: file.size,
            gameBannerUrl: gameBannerUrl,
            modImageUrls: modImageUrls,
            modDescription: modDescription,
            modAuthor: modAuthor
        )

        let result = downloadService.startDownload(file: file, gameName: gameName, modName: modName)

        switch result {
        case .success(let taskId):
            fileStates[fileId]?.taskId = taskId
            startObservingProgress(taskId: taskId, fileId: fileId)
        case .failure:
            fileStates[fileId]?.isDownloading = false
        }
    }

    func pauseDownload(fileId: Int) {
        guard let state = fileStates[fileId], let taskId = state.taskId else { return }
        downloadService.pauseDownload(taskId: taskId, fileId: fileId)
        fileStates[fileId]?.isPaused = true
        fileStates[fileId]?.isDownloading = false
        fileStates[fileId]?.taskId = nil
        progressTimers[taskId]?.invalidate()
        progressTimers.removeValue(forKey: taskId)
    }

    func isFileDownloading(_ fileId: Int) -> Bool {
        fileStates[fileId]?.isDownloading ?? false
    }

    func isFilePaused(_ fileId: Int) -> Bool {
        fileStates[fileId]?.isPaused ?? false
    }

    func fileProgress(_ fileId: Int) -> DownloadProgress? {
        fileStates[fileId]?.progress
    }

    func isFileDownloaded(_ fileId: Int) -> Bool {
        downloadHistory.isDownloaded(fileId: fileId)
    }

    func hasResumeData(for fileId: Int) -> Bool {
        downloadService.hasResumeData(for: fileId)
    }

    private func startObservingProgress(taskId: String, fileId: Int) {
        progressTimers[taskId]?.invalidate()
        progressTimers[taskId] = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] timer in
            Task { @MainActor [weak self] in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                if let progress = self.downloadService.activeDownloads[taskId] {
                    self.fileStates[fileId]?.progress = progress
                }
                if self.downloadService.completedDownloads.contains(taskId) {
                    self.fileStates[fileId]?.isCompleted = true
                    self.fileStates[fileId]?.isDownloading = false
                    self.fileStates[fileId]?.isPaused = false
                    self.recentCompletedFileId = fileId
                    self.downloadHistory.markDownloaded(fileId: fileId)
                    
                    if let info = self.pendingInfo[fileId] {
                        let historyItem = DownloadHistoryItem(
                            fileId: fileId,
                            fileName: info.fileName,
                            modName: info.modName,
                            gameName: info.gameName,
                            gameId: info.gameId,
                            fileSize: info.fileSize,
                            gameBannerUrl: info.gameBannerUrl,
                            modImageUrls: info.modImageUrls
                        )
                        self.downloadHistory.addHistoryItem(historyItem)
                        
                        if !info.gameName.isEmpty {
                            if let bannerUrl = info.gameBannerUrl {
                                self.setFolderIcon(imageUrl: bannerUrl, gameName: info.gameName, modName: nil)
                                self.saveImage(url: bannerUrl, gameName: info.gameName, modName: nil, filename: "game_banner.jpg")
                            }
                            if !info.modName.isEmpty {
                                if let modImageUrls = info.modImageUrls, !modImageUrls.isEmpty {
                                    if let firstImage = modImageUrls.first {
                                        self.setFolderIcon(imageUrl: firstImage, gameName: info.gameName, modName: info.modName)
                                    }
                                    self.saveAllImages(urls: modImageUrls, gameName: info.gameName, modName: info.modName)
                                }
                                self.saveModReadme(info: info)
                            }
                        }
                        
                        self.pendingInfo.removeValue(forKey: fileId)
                    }
                    
                    timer.invalidate()
                    self.progressTimers.removeValue(forKey: taskId)
                }
                if !(self.fileStates[fileId]?.isDownloading ?? false) && !(self.fileStates[fileId]?.isPaused ?? false) {
                    timer.invalidate()
                    self.progressTimers.removeValue(forKey: taskId)
                }
            }
        }
    }
    
    private func setFolderIcon(imageUrl: URL, gameName: String, modName: String?) {
        let sanitizedGameName = gameName
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: "\\", with: "_")
        
        var folderPath = configurationService.downloadDirectory.appendingPathComponent(sanitizedGameName)
        
        if let modName = modName, !modName.isEmpty {
            let sanitizedModName = modName
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: ":", with: "_")
                .replacingOccurrences(of: "\\", with: "_")
            folderPath = folderPath.appendingPathComponent(sanitizedModName)
        }
        
        guard FileManager.default.fileExists(atPath: folderPath.path) else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: imageUrl)
                guard let image = NSImage(data: data) else { return }
                
                let resizedImage = self.resizeImage(image, to: NSSize(width: 512, height: 512))
                
                let success = NSWorkspace.shared.setIcon(resizedImage, forFile: folderPath.path, options: [])
                if !success {
                    AppLogger.storage.warning("Failed to set folder icon via NSWorkspace")
                }
            } catch {
                AppLogger.storage.warning("Failed to download image for folder icon: \(error.localizedDescription)")
            }
        }
    }
    
    private func resizeImage(_ image: NSImage, to size: NSSize) -> NSImage {
        let resized = NSImage(size: size)
        resized.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: size), from: NSRect(origin: .zero, size: image.size), operation: .copy, fraction: 1.0)
        resized.unlockFocus()
        return resized
    }
    
    private func saveModReadme(info: PendingDownloadInfo) {
        let sanitizedGameName = info.gameName
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: "\\", with: "_")
        let sanitizedModName = info.modName
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: "\\", with: "_")
        
        let modFolderPath = configurationService.downloadDirectory
            .appendingPathComponent(sanitizedGameName)
            .appendingPathComponent(sanitizedModName)
        
        let readmePath = modFolderPath.appendingPathComponent("README.md")
        
        var content = "# \(info.modName)\n\n"
        if let author = info.modAuthor, !author.isEmpty {
            content += "**Author:** \(author)\n\n"
        }
        content += "**Game:** \(info.gameName)\n\n"
        content += "---\n\n"
        if let description = info.modDescription, !description.isEmpty {
            content += description
        } else {
            content += "*No description available.*"
        }
        
        do {
            try content.write(to: readmePath, atomically: true, encoding: .utf8)
        } catch {
            AppLogger.storage.warning("Failed to save README.md: \(error.localizedDescription)")
        }
    }
    
    private func saveImage(url: URL, gameName: String, modName: String?, filename: String) {
        var folderPath = configurationService.downloadDirectory
            .appendingPathComponent(sanitizeName(gameName))
        
        if let modName = modName, !modName.isEmpty {
            folderPath = folderPath.appendingPathComponent(sanitizeName(modName))
        }
        
        let imagePath = folderPath.appendingPathComponent(filename)
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                try data.write(to: imagePath)
            } catch {
                AppLogger.storage.warning("Failed to save image \(filename): \(error.localizedDescription)")
            }
        }
    }
    
    private func saveAllImages(urls: [URL], gameName: String, modName: String) {
        let folderPath = configurationService.downloadDirectory
            .appendingPathComponent(sanitizeName(gameName))
            .appendingPathComponent(sanitizeName(modName))
            .appendingPathComponent("images")
        
        Task {
            do {
                try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true)
                
                for (index, url) in urls.enumerated() {
                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        let ext = url.pathExtension.isEmpty ? "jpg" : url.pathExtension
                        let filename = "image_\(String(format: "%02d", index + 1)).\(ext)"
                        let imagePath = folderPath.appendingPathComponent(filename)
                        try data.write(to: imagePath)
                    } catch {
                        AppLogger.storage.warning("Failed to save image \(index + 1): \(error.localizedDescription)")
                    }
                }
            } catch {
                AppLogger.storage.warning("Failed to create images directory: \(error.localizedDescription)")
            }
        }
    }
    
    private func sanitizeName(_ name: String) -> String {
        name
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: "\\", with: "_")
    }
}
