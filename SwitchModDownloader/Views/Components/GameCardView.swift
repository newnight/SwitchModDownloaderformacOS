import SwiftUI

struct GameCardView: View {
    let game: Game
    let imageLoader: ImageLoader

    @State private var bannerImage: NSImage?
    @State private var imageLoadFailed: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if let bannerImage {
                    Image(nsImage: bannerImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if imageLoadFailed {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))
                        .overlay {
                            Button {
                                imageLoadFailed = false
                                loadBanner()
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                } else {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                        .overlay {
                            Image(systemName: "gamecontroller")
                                .foregroundColor(.gray)
                        }
                }
            }
            .frame(width: 80, height: 45)
            .clipped()
            .cornerRadius(6)

            VStack(alignment: .leading, spacing: 4) {
                Text(game.title)
                    .font(.headline)
                    .lineLimit(2)
                if let tid = game.tid {
                    Text(tid)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .task {
            loadBanner()
        }
    }

    private func loadBanner() {
        guard let bannerURL = game.bannerURL else { return }
        Task {
            if let img = await imageLoader.loadImage(from: bannerURL) {
                bannerImage = img
            } else {
                imageLoadFailed = true
            }
        }
    }
}
