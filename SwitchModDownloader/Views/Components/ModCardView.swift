import SwiftUI

struct ModCardView: View {
    let mod: Mod
    let imageLoader: ImageLoader
    let isDownloaded: Bool

    @State private var previewImage: NSImage?
    @State private var imageLoadFailed: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .topTrailing) {
                Group {
                    if let previewImage {
                        Image(nsImage: previewImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if imageLoadFailed {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.2))
                            .overlay {
                                Button {
                                    imageLoadFailed = false
                                    loadPreview()
                                } label: {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                    } else {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.2))
                            .overlay {
                                Image(systemName: "doc.richtext")
                                    .foregroundColor(.gray)
                            }
                    }
                }
                .frame(width: 60, height: 60)
                .clipped()
                .cornerRadius(6)
                
                if isDownloaded {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.green)
                        .background(Circle().fill(.white))
                        .offset(x: 4, y: -4)
                        .shadow(radius: 1)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(mod.name)
                        .font(.headline)
                        .lineLimit(2)
                    if isDownloaded {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }

                if let author = mod.author {
                    HStack(spacing: 4) {
                        Image(systemName: "person")
                            .font(.caption2)
                        Text(author)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }

                HStack(spacing: 12) {
                    if let downloadCount = mod.downloadCount {
                        Label("\(downloadCount)", systemImage: "arrow.down.circle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    if let commentCount = mod.commentCount {
                        Label("\(commentCount)", systemImage: "bubble.right.circle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    if let viewCount = mod.viewCount {
                        Label("\(viewCount)", systemImage: "eye.circle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .task {
            loadPreview()
        }
    }

    private func loadPreview() {
        guard let firstURL = mod.imageUrls?.first else { return }
        Task {
            if let img = await imageLoader.loadImage(from: firstURL) {
                previewImage = img
            } else {
                imageLoadFailed = true
            }
        }
    }
}
