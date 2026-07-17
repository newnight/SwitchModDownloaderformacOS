import Foundation

enum ModDownloaderError: Error, LocalizedError {
    case networkError(underlying: Error)
    case requestTimeout
    case noInternetConnection
    case apiError(statusCode: Int, message: String)
    case invalidResponse
    case dataParsingError(underlying: Error)
    case gameNotFound(keyword: String)
    case modNotFound(modId: Int)
    case emptyResult
    case downloadFailed(underlying: Error)
    case diskSpaceInsufficient(required: Int64, available: Int64)
    case downloadPathNotWritable(path: String)
    case downloadInterrupted
    case invalidConfiguration(key: String)
    case configurationLoadFailed

    var errorDescription: String? {
        switch self {
        case .networkError(let underlying):
            return "\(String(localized: "Network request failed")): \(underlying.localizedDescription)"
        case .requestTimeout:
            return String(localized: "Request timeout, please try again later")
        case .noInternetConnection:
            return String(localized: "Network unavailable, please check settings")
        case .apiError(let statusCode, let message):
            return "\(String(localized: "API Error")) (\(statusCode)): \(message)"
        case .invalidResponse:
            return String(localized: "Invalid response data")
        case .dataParsingError(let underlying):
            return "\(String(localized: "Data parse failed")): \(underlying.localizedDescription)"
        case .gameNotFound(let keyword):
            return "\(String(localized: "Game not found")): \(keyword)"
        case .modNotFound(let modId):
            return "\(String(localized: "Mod not found")): \(modId)"
        case .emptyResult:
            return String(localized: "No matching content found")
        case .downloadFailed(let underlying):
            return "\(String(localized: "Download failed")): \(underlying.localizedDescription)"
        case .diskSpaceInsufficient(let required, let available):
            let req = ByteCountFormatter.string(fromByteCount: required, countStyle: .file)
            let avail = ByteCountFormatter.string(fromByteCount: available, countStyle: .file)
            return "\(String(localized: "Insufficient disk space")), need \(req), available \(avail)"
        case .downloadPathNotWritable(let path):
            return "\(String(localized: "No write permission")): \(path)"
        case .downloadInterrupted:
            return String(localized: "Download interrupted")
        case .invalidConfiguration(let key):
            return "\(String(localized: "Invalid config")): \(key)"
        case .configurationLoadFailed:
            return String(localized: "Config load failed, using defaults")
        }
    }
}
