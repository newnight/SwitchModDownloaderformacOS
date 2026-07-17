import Foundation

protocol HTTPClientProtocol: AnyObject, Sendable {
    func get<T: Codable>(url: URL, params: [String: String]?) async throws -> T
    func download(url: URL, to: URL) async throws -> URL
}

final class HTTPClient: HTTPClientProtocol {
    private let session: URLSession
    private let timeout: TimeInterval = 15.0

    init(session: URLSession = .shared) {
        self.session = session
    }

    func get<T: Codable>(url: URL, params: [String: String]?) async throws -> T {
        let requestURL = try buildURL(url: url, params: params)
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        request.timeoutInterval = timeout
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("SwitchModDownloader/1.0", forHTTPHeaderField: "User-Agent")

        let data = try await sendRequestWithRetry(request)
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            AppLogger.network.error("JSON decode failed for \(requestURL.absoluteString): \(error.localizedDescription)")
            throw ModDownloaderError.dataParsingError(underlying: error)
        }
    }

    func download(url: URL, to destination: URL) async throws -> URL {
        let (localURL, _) = try await session.download(from: url)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }
        try fileManager.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
        try fileManager.moveItem(at: localURL, to: destination)
        return destination
    }

    private func buildURL(url: URL, params: [String: String]?) throws -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return url
        }
        if let params = params, !params.isEmpty {
            let existingItems = components.queryItems ?? []
            let newItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
            components.queryItems = existingItems + newItems
        }
        guard let resultURL = components.url else {
            throw ModDownloaderError.invalidConfiguration(key: "url")
        }
        return resultURL
    }

    private func sendRequestWithRetry(_ request: URLRequest) async throws -> Data {
        try await RetryPolicy.execute {
            let startTime = Date()
            let (data, response) = try await self.session.data(for: request)
            let elapsed = Date().timeIntervalSince(startTime)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ModDownloaderError.invalidResponse
            }

            AppLogger.network.info("\(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "") → \(httpResponse.statusCode) (\(String(format: "%.2f", elapsed))s)")

            guard (200...299).contains(httpResponse.statusCode) else {
                throw ModDownloaderError.apiError(
                    statusCode: httpResponse.statusCode,
                    message: "HTTP \(httpResponse.statusCode)"
                )
            }
            return data
        }
    }
}
