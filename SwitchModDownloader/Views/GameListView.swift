import SwiftUI

enum GameListViewMode: String, CaseIterable {
    case list = "list"
    case grid = "grid"

    var iconName: String {
        switch self {
        case .list: return "list.bullet"
        case .grid: return "square.grid.2x2"
        }
    }
}

struct GameListView: View {
    @ObservedObject var viewModel: SearchViewModel
    let onSelectGame: (Game) -> Void
    let imageLoader: ImageLoader
    @ObservedObject var settingsViewModel: SettingsViewModel

    @State private var viewMode: GameListViewMode

    init(viewModel: SearchViewModel, onSelectGame: @escaping (Game) -> Void, imageLoader: ImageLoader, settingsViewModel: SettingsViewModel) {
        self.viewModel = viewModel
        self.onSelectGame = onSelectGame
        self.imageLoader = imageLoader
        self.settingsViewModel = settingsViewModel
        _viewMode = State(initialValue: settingsViewModel.selectedDefaultViewMode == .grid ? .grid : .list)
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingStateView(state: .loading, retryAction: nil)
            } else if viewModel.games.isEmpty {
                if viewModel.errorMessage != nil {
                    EmptyView()
                } else {
                    LoadingStateView(state: .idle, retryAction: nil)
                }
            } else {
                VStack(spacing: 0) {
                    HStack {
                        if viewModel.totalCount > 0 {
                            Text("\(String(localized: "Total results")) \(viewModel.totalCount), \(String(localized: "Page")) \(viewModel.currentPage), \(viewModel.games.count) \(String(localized: "loaded"))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(nsColor: .controlBackgroundColor).opacity(0.8))
                                .cornerRadius(4)
                        }
                        Spacer()
                        Picker("", selection: $viewMode) {
                            ForEach(GameListViewMode.allCases, id: \.self) { mode in
                                Image(systemName: mode.iconName).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 80)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)

                    if viewMode == .list {
                        gameList
                    } else {
                        gameGrid
                    }
                }
            }
        }
        .onAppear {
            viewMode = settingsViewModel.selectedDefaultViewMode == .grid ? .grid : .list
        }
        .onChange(of: settingsViewModel.selectedDefaultViewMode) { _, newValue in
            viewMode = newValue == .grid ? .grid : .list
        }
    }

    private var gameList: some View {
        List {
            ForEach(viewModel.games) { game in
                Button {
                    onSelectGame(game)
                } label: {
                    GameCardView(game: game, imageLoader: imageLoader)
                }
                .buttonStyle(.plain)
            }

            if viewModel.hasMoreResults {
                Button {
                    Task { await viewModel.loadMoreGames() }
                } label: {
                    HStack {
                        Spacer()
                        if viewModel.isLoadingMore {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Text(String(localized: "Load More"))
                                .foregroundColor(.accentColor)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isLoadingMore)
            }
        }
        .listStyle(.inset)
    }

    private var gameGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 16)
            ], spacing: 16) {
                ForEach(viewModel.games) { game in
                    Button {
                        onSelectGame(game)
                    } label: {
                        GameGridItemView(game: game, imageLoader: imageLoader)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)

            if viewModel.hasMoreResults {
                Button {
                    Task { await viewModel.loadMoreGames() }
                } label: {
                    HStack {
                        Spacer()
                        if viewModel.isLoadingMore {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Text(String(localized: "Load More"))
                                .foregroundColor(.accentColor)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isLoadingMore)
                .padding(.horizontal, 16)
            }
        }
    }
}

struct GameGridItemView: View {
    let game: Game
    let imageLoader: ImageLoader

    @State private var bannerImage: NSImage?
    @State private var imageLoadFailed: Bool = false

    var body: some View {
        VStack(spacing: 6) {
            Group {
                if let bannerImage {
                    Image(nsImage: bannerImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if imageLoadFailed {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .overlay {
                            Button {
                                imageLoadFailed = false
                                loadBanner()
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .overlay {
                            Image(systemName: "gamecontroller")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                }
            }
            .frame(height: 90)
            .clipped()
            .cornerRadius(8)

            Text(game.title)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(height: 32)
        }
        .frame(minWidth: 160)
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(10)
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
