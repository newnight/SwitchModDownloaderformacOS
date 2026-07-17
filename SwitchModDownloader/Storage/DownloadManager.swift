import Foundation

protocol DownloadManagerProtocol {
    func startDownload(url: URL, to destination: URL) -> DownloadTaskInfo
    func resumeDownload(url: URL, to destination: URL, resumeData: Data) -> DownloadTaskInfo
    func cancelDownload(taskId: String) -> Data?
    func pauseDownload(taskId: String) -> Data?
}

final class DownloadManager: NSObject, DownloadManagerProtocol {
    private var session: URLSession!
    private var activeTasks: [String: URLSessionDownloadTask] = [:]
    private var taskProgressHandlers: [String: (DownloadProgress) -> Void] = [:]
    private var taskCompletionHandlers: [String: (Result<URL, Error>) -> Void] = [:]
    private var taskDestinations: [String: URL] = [:]
    private var taskStartTimes: [String: Date] = [:]
    private var lastProgressUpdate: [String: Date] = [:]
    private var taskResumeData: [String: Data] = [:]
    private var taskUrls: [String: URL] = [:]

    override init() {
        super.init()
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }

    func startDownload(url: URL, to destination: URL) -> DownloadTaskInfo {
        let taskId = UUID().uuidString
        let request = URLRequest(url: url)
        let task = session.downloadTask(with: request)
        activeTasks[taskId] = task
        taskDestinations[taskId] = destination
        taskUrls[taskId] = url
        taskStartTimes[taskId] = Date()
        task.resume()
        return DownloadTaskInfo(id: taskId, url: url, destination: destination)
    }

    func resumeDownload(url: URL, to destination: URL, resumeData: Data) -> DownloadTaskInfo {
        let taskId = UUID().uuidString
        let task = session.downloadTask(withResumeData: resumeData)
        activeTasks[taskId] = task
        taskDestinations[taskId] = destination
        taskUrls[taskId] = url
        taskStartTimes[taskId] = Date()
        task.resume()
        return DownloadTaskInfo(id: taskId, url: url, destination: destination)
    }

    func cancelDownload(taskId: String) -> Data? {
        let task = activeTasks[taskId]
        let data = taskResumeData[taskId]
        task?.cancel()
        cleanup(taskId)
        return data
    }

    func pauseDownload(taskId: String) -> Data? {
        guard let task = activeTasks[taskId] else { return nil }
        let data = taskResumeData[taskId]
        task.cancel(byProducingResumeData: { [weak self] resumeData in
            if let resumeData = resumeData {
                self?.taskResumeData[taskId] = resumeData
            }
        })
        activeTasks.removeValue(forKey: taskId)
        return data ?? taskResumeData[taskId]
    }

    func hasActiveTask(_ taskId: String) -> Bool {
        activeTasks[taskId] != nil
    }

    func onProgress(taskId: String, handler: @escaping (DownloadProgress) -> Void) {
        taskProgressHandlers[taskId] = handler
    }

    func onCompletion(taskId: String, handler: @escaping (Result<URL, Error>) -> Void) {
        taskCompletionHandlers[taskId] = handler
    }
}

struct DownloadTaskInfo {
    let id: String
    let url: URL
    let destination: URL
}

extension DownloadManager: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let taskId = findTaskId(for: downloadTask) else { return }

        let now = Date()
        let throttleInterval: TimeInterval = 0.2
        if let lastUpdate = lastProgressUpdate[taskId], now.timeIntervalSince(lastUpdate) < throttleInterval {
            return
        }
        lastProgressUpdate[taskId] = now

        let speed: Int64
        if let startTime = taskStartTimes[taskId] {
            let elapsed = now.timeIntervalSince(startTime)
            speed = elapsed > 0 ? Int64(Double(totalBytesWritten) / elapsed) : 0
        } else {
            speed = 0
        }

        let remainingTime: TimeInterval?
        if speed > 0 {
            let remaining = Int64(totalBytesExpectedToWrite) - totalBytesWritten
            remainingTime = Double(remaining) / Double(speed)
        } else {
            remainingTime = nil
        }

        let progress = DownloadProgress(
            taskId: taskId,
            bytesWritten: totalBytesWritten,
            totalBytes: totalBytesExpectedToWrite,
            speed: speed,
            remainingTime: remainingTime
        )
        taskProgressHandlers[taskId]?(progress)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let taskId = findTaskId(for: downloadTask),
              let destination = taskDestinations[taskId] else { return }

        do {
            let fm = FileManager.default
            if fm.fileExists(atPath: destination.path) {
                try fm.removeItem(at: destination)
            }
            try fm.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
            try fm.moveItem(at: location, to: destination)
            taskCompletionHandlers[taskId]?(.success(destination))
        } catch {
            taskCompletionHandlers[taskId]?(.failure(error))
        }
        cleanup(taskId)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let taskId = findTaskId(for: task as! URLSessionDownloadTask) else { return }
        let nsError = error as? NSError

        if let error = error {
            if nsError?.code == NSURLErrorCancelled {
                if let resumeData = (error as NSError).userInfo[NSURLSessionDownloadTaskResumeData] as? Data {
                    taskResumeData[taskId] = resumeData
                }
                return
            }
            taskCompletionHandlers[taskId]?(.failure(error))
            cleanup(taskId)
        }
    }

    private func findTaskId(for task: URLSessionDownloadTask) -> String? {
        activeTasks.first(where: { $0.value === task })?.key
    }

    private func cleanup(_ taskId: String) {
        activeTasks.removeValue(forKey: taskId)
        taskProgressHandlers.removeValue(forKey: taskId)
        taskCompletionHandlers.removeValue(forKey: taskId)
        taskDestinations.removeValue(forKey: taskId)
        taskStartTimes.removeValue(forKey: taskId)
        lastProgressUpdate.removeValue(forKey: taskId)
        taskResumeData.removeValue(forKey: taskId)
        taskUrls.removeValue(forKey: taskId)
    }
}
