import SwiftUI

struct ModDetailView: View {
    @ObservedObject var viewModel: ModDetailViewModel
    @ObservedObject var downloadViewModel: DownloadViewModel
    let imageLoader: ImageLoader
    let game: Game  // 直接接收 Game 对象

    @State private var selectedFile: File?

    var body: some View {
        Group {
            if let mod = viewModel.mod, !viewModel.isLoading {
                modContent(mod)
            } else if let error = viewModel.errorMessage, !viewModel.isLoading {
                LoadingStateView(state: .error(error), retryAction: {
                    Task { await viewModel.retry() }
                })
            } else {
                LoadingStateView(state: .loading, retryAction: nil)
            }
        }
    }

    private func modContent(_ mod: Mod) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(mod.name)
                        .font(.title)
                        .fontWeight(.bold)

                    HStack(spacing: 16) {
                        if let author = mod.author {
                            Label(author, systemImage: "person")
                                .foregroundColor(.secondary)
                        }
                        if let downloadCount = mod.downloadCount {
                            Label("\(downloadCount)", systemImage: "arrow.down.circle")
                                .foregroundColor(.secondary)
                        }
                        if let commentCount = mod.commentCount {
                            Label("\(commentCount)", systemImage: "bubble.right.circle")
                                .foregroundColor(.secondary)
                        }
                        if let likeCount = mod.likeCount {
                            Label("\(likeCount)", systemImage: "heart.circle")
                                .foregroundColor(.secondary)
                        }
                    }
                    .font(.subheadline)
                }
                .padding(.horizontal, 16)

                if let imageUrls = mod.imageUrls, !imageUrls.isEmpty {
                    ScreenshotGallery(imageUrls: imageUrls, imageLoader: imageLoader)
                        .padding(.horizontal, 16)
                }

                if let description = viewModel.formattedDescription, !description.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "Description"))
                            .font(.headline)
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }
                    .padding(.horizontal, 16)
                }

                if let files = mod.files, !files.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(String(localized: "Files"))
                                .font(.headline)
                            Spacer()
                            let undownloadedFiles = files.filter { !downloadViewModel.isFileDownloaded($0.fileID) && !downloadViewModel.isFileDownloading($0.fileID) }
                            if !undownloadedFiles.isEmpty {
                                Button {
                                    let gameName = game.title
                                    let modName = mod.name
                                    for file in undownloadedFiles {
                                        downloadViewModel.startDownload(
                                            file: file,
                                            modName: modName,
                                            gameName: gameName,
                                            gameId: game.gamebananaID,
                                            gameBannerUrl: game.bannerURL,
                                            modImageUrls: mod.imageUrls,
                                            modDescription: viewModel.formattedDescription,
                                            modAuthor: mod.author
                                        )
                                    }
                                } label: {
                                    Label("\(String(localized: "Download All")) (\(undownloadedFiles.count))", systemImage: "arrow.down.circle")
                                        .font(.caption)
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .padding(.horizontal, 16)

                        ForEach(files) { file in
                            FileRowView(
                                file: file,
                                modName: mod.name,
                                gameName: game.title,
                                gameId: game.gamebananaID,
                                gameBannerUrl: game.bannerURL,
                                modImageUrls: mod.imageUrls,
                                modDescription: viewModel.formattedDescription,
                                modAuthor: mod.author,
                                isDownloaded: downloadViewModel.isFileDownloaded(file.fileID),
                                isDownloading: downloadViewModel.isFileDownloading(file.fileID),
                                isPaused: downloadViewModel.isFilePaused(file.fileID),
                                downloadProgress: downloadViewModel.fileProgress(file.fileID),
                                downloadViewModel: downloadViewModel
                            )
                            .padding(.horizontal, 16)
                        }
                    }
                }

                if let completedId = downloadViewModel.recentCompletedFileId {
                    Label(String(localized: "Download Complete"), systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .transition(.opacity)
                        .animation(.easeIn(duration: 0.3), value: completedId)
                }
            }
            .padding(.vertical, 8)
        }
    }
}

struct ScreenshotGallery: View {
    let imageUrls: [URL]
    let imageLoader: ImageLoader

    @State private var selectedIndex: Int = 0
    @State private var images: [Int: NSImage] = [:]
    @State private var failedIndices: Set<Int> = []

    var body: some View {
        VStack(spacing: 8) {
            if failedIndices.contains(selectedIndex) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 200)
                    .overlay {
                        VStack(spacing: 4) {
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            Text(String(localized: "Image load failed"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
            } else if let mainImage = images[selectedIndex] {
                Image(nsImage: mainImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 300)
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 200)
                    .overlay { ProgressView() }
            }

            if imageUrls.count > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(imageUrls.indices, id: \.self) { index in
                            Group {
                                if let img = images[index] {
                                    Image(nsImage: img)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } else if failedIndices.contains(index) {
                                    Color.gray.opacity(0.1)
                                        .overlay {
                                            Image(systemName: "exclamationmark.triangle")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                } else {
                                    Color.gray.opacity(0.2)
                                }
                            }
                            .frame(width: 60, height: 40)
                            .clipped()
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(selectedIndex == index ? Color.accentColor : Color.clear, lineWidth: 2)
                            )
                            .onTapGesture { selectedIndex = index }
                        }
                    }
                }
            }
        }
        .task {
            await loadAllImages()
        }
    }

    private func loadAllImages() async {
        for index in imageUrls.indices {
            let img = await imageLoader.loadImage(from: imageUrls[index])
            if let img {
                images[index] = img
            } else {
                failedIndices.insert(index)
            }
        }
    }
}

struct FileRowView: View {
    let file: File
    let modName: String
    let gameName: String
    let gameId: Int
    let gameBannerUrl: URL?
    let modImageUrls: [URL]?
    let modDescription: String?
    let modAuthor: String?
    let isDownloaded: Bool
    let isDownloading: Bool
    let isPaused: Bool
    let downloadProgress: DownloadProgress?
    @ObservedObject var downloadViewModel: DownloadViewModel

    @State private var showCopiedTooltip = false

    private var canResume: Bool {
        downloadViewModel.hasResumeData(for: file.fileID)
    }

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(file.name)
                        .font(.subheadline)
                        .lineLimit(1)
                    if isDownloaded {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    if isPaused {
                        Text(String(localized: "Paused"))
                            .font(.caption2)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.orange.opacity(0.15))
                            .cornerRadius(3)
                    }
                }
                HStack(spacing: 8) {
                    if isDownloading || isPaused, let progress = downloadProgress {
                        Text("\(formatBytes(progress.bytesWritten))/\(formatBytes(progress.totalBytes))")
                        if let remaining = progress.formattedRemainingTime {
                            Text("\(String(localized: "Remaining")) \(remaining)")
                        }
                    } else {
                        Text(file.formattedSize)
                    }
                    if let date = file.date {
                        Text(date, style: .date)
                    }
                    if let romfs = file.romfs {
                        Text(romfs ? "✓ romfs" : "✗ romfs")
                            .foregroundColor(romfs ? .green : .orange)
                            .font(.caption)
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()

            Button {
                if isDownloading {
                    downloadViewModel.pauseDownload(fileId: file.fileID)
                } else {
                    downloadViewModel.startDownload(
                        file: file,
                        modName: modName,
                        gameName: gameName,
                        gameId: gameId,
                        gameBannerUrl: gameBannerUrl,
                        modImageUrls: modImageUrls,
                        modDescription: modDescription,
                        modAuthor: modAuthor
                    )
                }
            } label: {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 3)
                        .frame(width: 28, height: 28)
                    if isDownloading {
                        Circle()
                            .trim(from: 0, to: downloadProgress?.progress ?? 0)
                            .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .frame(width: 28, height: 28)
                            .rotationEffect(.degrees(-90))
                        Image(systemName: "pause.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.accentColor)
                    } else if isPaused || canResume {
                        Image(systemName: "arrow.uturn.forward.circle")
                            .font(.system(size: 14))
                            .foregroundColor(.orange)
                    } else {
                        Image(systemName: isDownloaded ? "arrow.down.circle.fill" : "arrow.down")
                            .font(.system(size: 14))
                            .foregroundColor(isDownloaded ? .green : .accentColor)
                    }
                }
            }
            .buttonStyle(.plain)
            .help(isPaused || canResume ? String(localized: "Resume Download") : (isDownloaded ? String(localized: "Re-download") : String(localized: "Download")))

            Button {
                copyDownloadURL()
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help(String(localized: "Copy Download Link"))
            .overlay {
                if showCopiedTooltip {
                    Text(String(localized: "Copied"))
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(4)
                        .shadow(radius: 1)
                        .offset(y: -20)
                        .transition(.opacity)
                }
            }
        }
        .padding(8)
        .background {
            ZStack(alignment: .leading) {
                if isDownloaded && !isDownloading {
                    Color.green.opacity(0.1)
                } else {
                    Color(nsColor: .controlBackgroundColor)
                }
                if isDownloading {
                    Color.accentColor.opacity(0.08)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Color.accentColor.opacity(0.15)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .mask(
                            GeometryReader { geo in
                                Rectangle()
                                    .size(width: geo.size.width * (downloadProgress?.progress ?? 0), height: geo.size.height)
                            }
                        )
                }
            }
        }
        .cornerRadius(6)
    }

    private func copyDownloadURL() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(file.url.absoluteString, forType: .string)
        showCopiedTooltip = true
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            showCopiedTooltip = false
        }
    }

    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
