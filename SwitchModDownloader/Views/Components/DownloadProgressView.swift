import SwiftUI

struct DownloadProgressView: View {
    let progress: DownloadProgress?

    var body: some View {
        VStack(spacing: 8) {
            if let progress {
                ProgressView(value: progress.progress) {
                    Text(String(format: "%.1f%%", progress.progress * 100))
                        .font(.headline)
                } currentValueLabel: {
                    HStack(spacing: 16) {
                        Text(progress.formattedSpeed)
                        if let remaining = progress.formattedRemainingTime {
                            Text("\(String(localized: "Remaining")) \(remaining)")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .progressViewStyle(.linear)
            } else {
                ProgressView()
                    .progressViewStyle(.linear)
            }
        }
    }
}
