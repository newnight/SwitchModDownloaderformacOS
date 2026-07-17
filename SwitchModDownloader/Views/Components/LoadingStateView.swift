import SwiftUI

enum LoadingState {
    case idle
    case loading
    case empty
    case error(String)
}

struct LoadingStateView: View {
    let state: LoadingState
    let retryAction: (() -> Void)?

    var body: some View {
        switch state {
        case .idle:
            EmptyView()
        case .loading:
            VStack(spacing: 8) {
                ProgressView()
                    .controlSize(.large)
                Text(String(localized: "Loading..."))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .empty:
            VStack(spacing: 8) {
                Image(systemName: "tray")
                    .font(.system(size: 40))
                    .foregroundColor(.secondary)
                Text(String(localized: "No content"))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .error(let message):
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
                Text(message)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                if let retryAction {
                    Button(String(localized: "Retry"), action: retryAction)
                        .buttonStyle(.borderedProminent)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
