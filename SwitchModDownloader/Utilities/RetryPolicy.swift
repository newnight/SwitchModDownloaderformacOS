import Foundation

enum RetryPolicy {
    static let maxRetries = 3
    static let baseDelay: TimeInterval = 1.0

    static func execute<T>(_ operation: @Sendable () async throws -> T) async throws -> T {
        var lastError: Error?
        for attempt in 0..<maxRetries {
            do {
                return try await operation()
            } catch {
                lastError = error
                if attempt < maxRetries - 1 {
                    let delay = baseDelay * pow(2.0, Double(attempt))
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
        throw lastError!
    }
}
