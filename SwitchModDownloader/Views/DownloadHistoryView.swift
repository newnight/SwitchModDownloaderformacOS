import SwiftUI

struct DownloadHistoryView: View {
    @ObservedObject var downloadViewModel: DownloadViewModel
    let configurationService: ConfigurationService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            headerBar
            Divider()
            
            let activeCount = downloadViewModel.fileStates.values.filter { $0.isDownloading }.count
            if activeCount > 0 {
                activeDownloadsSection
            } else {
                emptyView
            }
        }
        .frame(minWidth: 400, minHeight: 200)
    }
    
    private var headerBar: some View {
        HStack {
            Text(String(localized: "Download Manager"))
                .font(.headline)
            Spacer()
            Button {
                NSWorkspace.shared.open(configurationService.downloadDirectory)
            } label: {
                Label(String(localized: "Open Directory"), systemImage: "folder")
            }
            .buttonStyle(.bordered)
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var activeDownloadsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "Downloading"))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
                .padding(.top, 8)
            
            let activeFiles = downloadViewModel.fileStates.filter { $0.value.isDownloading }
            ForEach(Array(activeFiles.keys), id: \.self) { fileId in
                if let state = activeFiles[fileId], let progress = state.progress {
                    HStack(spacing: 12) {
                        ProgressView(value: progress.progress)
                            .progressViewStyle(.linear)
                            .frame(width: 120)
                        Text("\(Int(progress.progress * 100))%")
                            .font(.caption)
                            .frame(width: 40)
                        Text(progress.formattedSpeed)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if let remaining = progress.formattedRemainingTime {
                            Text(remaining)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .padding(.bottom, 8)
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "arrow.down.circle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text(String(localized: "No active downloads"))
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}
