import Foundation

struct DownloadProgress {
    let taskId: String
    let bytesWritten: Int64
    let totalBytes: Int64
    let speed: Int64
    let remainingTime: TimeInterval?

    var progress: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(bytesWritten) / Double(totalBytes)
    }

    var formattedSpeed: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: speed)
    }

    var formattedRemainingTime: String? {
        guard let remaining = remainingTime, remaining > 0 else { return nil }
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
