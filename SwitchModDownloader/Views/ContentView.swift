import SwiftUI

enum NavigationRoute: Hashable {
    case modList(Game)
    case modDetail(Mod, Game)  // 添加 Game 参数
}

struct ContentView: View {
    @ObservedObject var searchViewModel: SearchViewModel
    @ObservedObject var modListViewModel: ModListViewModel
    @ObservedObject var modDetailViewModel: ModDetailViewModel
    @ObservedObject var downloadViewModel: DownloadViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var downloadHistory: DownloadHistoryManager
    let configurationService: ConfigurationService

    @State private var navigationPath = NavigationPath()
    @State private var selectedTab: AppTab = .search
    @State private var showDownloadHistory = false

    private let imageLoader: ImageLoader

    init(
        searchViewModel: SearchViewModel,
        modListViewModel: ModListViewModel,
        modDetailViewModel: ModDetailViewModel,
        downloadViewModel: DownloadViewModel,
        settingsViewModel: SettingsViewModel,
        downloadHistory: DownloadHistoryManager,
        configurationService: ConfigurationService
    ) {
        self.searchViewModel = searchViewModel
        self.modListViewModel = modListViewModel
        self.modDetailViewModel = modDetailViewModel
        self.downloadViewModel = downloadViewModel
        self.settingsViewModel = settingsViewModel
        self.downloadHistory = downloadHistory
        self.configurationService = configurationService

        let cacheManager = CacheManager()
        self.imageLoader = ImageLoader(cacheManager: cacheManager)
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            mainContent
                .navigationDestination(for: NavigationRoute.self) { route in
                    switch route {
                    case .modList(let game):
                        ModListView(
                            viewModel: modListViewModel,
                            downloadViewModel: downloadViewModel,
                            onSelectMod: { mod in
                                navigationPath.append(NavigationRoute.modDetail(mod, game))
                            },
                            imageLoader: imageLoader,
                            settingsViewModel: settingsViewModel
                        )
                        .task { await modListViewModel.loadMods(for: game, sortBy: settingsViewModel.selectedDefaultModSort) }

                    case .modDetail(let mod, let game):
                        ModDetailView(
                            viewModel: modDetailViewModel,
                            downloadViewModel: downloadViewModel,
                            imageLoader: imageLoader,
                            game: game
                        )
                        .task { await modDetailViewModel.loadModDetail(modId: mod.modID) }
                    }
                }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                Button {
                    if navigationPath.count > 0 {
                        navigationPath.removeLast()
                    }
                    selectedTab = .search
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                .tint(selectedTab == .search ? .accentColor : .secondary)

                Button {
                    if navigationPath.count > 0 {
                        navigationPath = NavigationPath()
                    }
                    selectedTab = .settings
                } label: {
                    Image(systemName: "gearshape")
                }
                .tint(selectedTab == .settings ? .accentColor : .secondary)
            }
            
            ToolbarItemGroup(placement: .primaryAction) {
                downloadProgressButton
            }
        }
        .sheet(isPresented: $showDownloadHistory) {
            DownloadHistoryView(
                downloadViewModel: downloadViewModel,
                configurationService: configurationService
            )
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        VStack(spacing: 0) {
            SearchView(viewModel: searchViewModel)

            if selectedTab == .search {
                GameListView(
                    viewModel: searchViewModel,
                    onSelectGame: { game in
                        navigationPath.append(NavigationRoute.modList(game))
                    },
                    imageLoader: imageLoader,
                    settingsViewModel: settingsViewModel
                )
            } else {
                SettingsView(viewModel: settingsViewModel)
            }
        }
    }
    
    private var downloadProgressButton: some View {
        let activeDownloads = downloadViewModel.fileStates.values.filter { $0.isDownloading }
        let activeCount = activeDownloads.count
        let totalProgress = activeDownloads.compactMap { $0.progress?.progress }.reduce(0.0, +) / Double(max(activeCount, 1))
        
        return Button {
            showDownloadHistory = true
        } label: {
            HStack(spacing: 4) {
                if activeCount > 0 {
                    ZStack {
                        Circle()
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 2)
                            .frame(width: 18, height: 18)
                        Circle()
                            .trim(from: 0, to: totalProgress)
                            .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .frame(width: 18, height: 18)
                            .rotationEffect(.degrees(-90))
                        Text("\(activeCount)")
                            .font(.system(size: 9, weight: .bold))
                    }
                } else {
                    Image(systemName: "arrow.down.circle")
                }
            }
        }
        .help(activeCount > 0 ? "\(String(localized: "Downloading files")) (\(activeCount))" : String(localized: "Download Manager"))
    }
}

enum AppTab: Hashable {
    case search
    case settings
}
