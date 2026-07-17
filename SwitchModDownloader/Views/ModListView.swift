import SwiftUI

enum ModListViewMode: String, CaseIterable {
    case list = "list"
    case grid = "grid"

    var iconName: String {
        switch self {
        case .list: return "list.bullet"
        case .grid: return "square.grid.2x2"
        }
    }
}

struct ModListView: View {
    @ObservedObject var viewModel: ModListViewModel
    @ObservedObject var downloadViewModel: DownloadViewModel
    let onSelectMod: (Mod) -> Void
    let imageLoader: ImageLoader
    @ObservedObject var settingsViewModel: SettingsViewModel

    @State private var modSearchText = ""
    @State private var viewMode: ModListViewMode
    @State private var jumpToPageText = ""

    init(viewModel: ModListViewModel, downloadViewModel: DownloadViewModel, onSelectMod: @escaping (Mod) -> Void, imageLoader: ImageLoader, settingsViewModel: SettingsViewModel) {
        self.viewModel = viewModel
        self.downloadViewModel = downloadViewModel
        self.onSelectMod = onSelectMod
        self.imageLoader = imageLoader
        self.settingsViewModel = settingsViewModel
        _viewMode = State(initialValue: settingsViewModel.selectedDefaultViewMode == .grid ? .grid : .list)
    }

    var body: some View {
        VStack(spacing: 0) {
            if let game = viewModel.currentGame {
                gameHeader(game)
            }

            filterBar

            if viewModel.isLoading {
                LoadingStateView(state: .loading, retryAction: nil)
            } else if viewModel.mods.isEmpty {
                LoadingStateView(
                    state: viewModel.errorMessage != nil
                        ? .error(viewModel.errorMessage!)
                        : .empty,
                    retryAction: { Task { await viewModel.loadFirstPage() } }
                )
            } else {
                if viewMode == .list {
                    modList
                } else {
                    modGrid
                }
            }
        }
        .onAppear {
            viewMode = settingsViewModel.selectedDefaultViewMode == .grid ? .grid : .list
        }
        .onChange(of: settingsViewModel.selectedDefaultViewMode) { _, newValue in
            viewMode = newValue == .grid ? .grid : .list
        }
        .onChange(of: settingsViewModel.selectedDefaultModSort) { _, newValue in
            if viewModel.sortBy != newValue {
                viewModel.sortBy = newValue
                Task { await viewModel.selectSort(newValue) }
            }
        }
    }

    private func gameHeader(_ game: Game) -> some View {
        Text(game.title)
            .font(.title2)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
    }

    private var filterBar: some View {
        HStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField(String(localized: "Search Mods..."), text: $modSearchText)
                    .onSubmit {
                        Task { await viewModel.searchMods(keyword: modSearchText) }
                    }
                if !modSearchText.isEmpty {
                    Button {
                        modSearchText = ""
                        Task { await viewModel.searchMods(keyword: "") }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .textFieldStyle(.roundedBorder)

            Picker("", selection: $viewModel.sortBy) {
                ForEach(ModFilters.SortOption.allCases, id: \.self) { option in
                    Text(option.displayName).tag(option)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 90)
            .onChange(of: viewModel.sortBy) { _, _ in
                Task { await viewModel.selectSort(viewModel.sortBy) }
            }

            Picker("", selection: $viewMode) {
                ForEach(ModListViewMode.allCases, id: \.self) { mode in
                    Image(systemName: mode.iconName).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 80)

            Spacer()

            if viewModel.totalPages > 1 {
                paginationBar
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }

    private var paginationBar: some View {
        HStack(spacing: 4) {
            Button {
                Task { await viewModel.loadPage(viewModel.currentPage - 1) }
            } label: {
                Image(systemName: "chevron.left")
            }
            .disabled(viewModel.currentPage <= 1 || viewModel.isLoadingMore)
            .buttonStyle(.bordered)

            TextField("\(viewModel.currentPage)", text: $jumpToPageText)
                .textFieldStyle(.roundedBorder)
                .frame(width: 36)
                .font(.caption)
                .onSubmit {
                    if let page = Int(jumpToPageText), page >= 1, page <= viewModel.totalPages {
                        Task { await viewModel.loadPage(page) }
                    }
                    jumpToPageText = ""
                }

            Text("/\(viewModel.totalPages)")
                .font(.caption)
                .foregroundColor(.secondary)

            Button {
                Task { await viewModel.loadPage(viewModel.currentPage + 1) }
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(viewModel.currentPage >= viewModel.totalPages || viewModel.isLoadingMore)
            .buttonStyle(.bordered)
        }
    }

    private func modIndex(_ mod: Mod) -> Int {
        guard let idx = viewModel.mods.firstIndex(where: { $0.id == mod.id }) else { return 0 }
        return (viewModel.currentPage - 1) * 50 + idx + 1
    }

    private var modList: some View {
        List(viewModel.mods) { mod in
            Button {
                onSelectMod(mod)
            } label: {
                HStack(spacing: 4) {
                    Text("\(modIndex(mod))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(width: 24, alignment: .trailing)
                    ModCardView(
                        mod: mod,
                        imageLoader: imageLoader,
                        isDownloaded: mod.files?.contains(where: { downloadViewModel.isFileDownloaded($0.fileID) }) ?? false
                    )
                }
            }
            .buttonStyle(.plain)
        }
        .listStyle(.inset)
        .overlay {
            if viewModel.isLoadingMore {
                ProgressView()
                    .controlSize(.small)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 8)
            }
        }
    }

    private var modGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 180, maximum: 240), spacing: 16)
            ], spacing: 16) {
                ForEach(viewModel.mods) { mod in
                    Button {
                        onSelectMod(mod)
                    } label: {
                        ModGridItemView(
                            index: modIndex(mod),
                            mod: mod,
                            imageLoader: imageLoader,
                            isDownloaded: mod.files?.contains(where: { downloadViewModel.isFileDownloaded($0.fileID) }) ?? false
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8)

            if viewModel.isLoadingMore {
                ProgressView()
                    .controlSize(.small)
                    .padding(.bottom, 8)
            }
        }
    }
}

struct ModGridItemView: View {
    let index: Int
    let mod: Mod
    let imageLoader: ImageLoader
    let isDownloaded: Bool

    @State private var previewImage: NSImage?
    @State private var imageLoadFailed: Bool = false

    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .topLeading) {
                ZStack(alignment: .topTrailing) {
                    Group {
                        if let previewImage {
                            Image(nsImage: previewImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else if imageLoadFailed {
                            Color.gray.opacity(0.2)
                                .overlay {
                                    Button {
                                        imageLoadFailed = false
                                        loadPreview()
                                    } label: {
                                        Image(systemName: "arrow.clockwise")
                                            .foregroundColor(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                }
                        } else {
                            Color.gray.opacity(0.2)
                                .overlay {
                                    Image(systemName: "doc.richtext")
                                        .foregroundColor(.gray)
                                }
                        }
                    }
                    .frame(height: 100)
                    .clipped()
                    .cornerRadius(8)
                    
                    if isDownloaded {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.green)
                            .background(Circle().fill(.white))
                            .offset(x: 4, y: 4)
                            .shadow(radius: 1)
                    }
                }

                Text("\(index)")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(4)
                    .padding(4)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(mod.name)
                        .font(.caption)
                        .lineLimit(2)
                    if isDownloaded {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
                if let author = mod.author {
                    Text(author)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                if let downloadCount = mod.downloadCount {
                    Label("\(downloadCount)", systemImage: "arrow.down.circle")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(10)
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

struct CategoryPill: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(isSelected ? Color.accentColor : Color.gray.opacity(0.15))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}
