import Foundation

@MainActor
class ModListViewModel: ObservableObject {
    @Published var mods: [Mod] = []
    @Published var currentGame: Game?
    @Published var modSearchKeyword: String = ""
    @Published var sortBy: ModFilters.SortOption = .popularity
    @Published var currentPage: Int = 1
    @Published var totalPages: Int = 1
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var errorMessage: String?

    private let modService: ModService
    private var currentGameId: Int?

    init(modService: ModService) {
        self.modService = modService
    }

    func loadMods(for game: Game, sortBy: ModFilters.SortOption? = nil) async {
        currentGame = game
        currentGameId = game.gamebananaID
        modSearchKeyword = ""
        if let sortBy = sortBy {
            self.sortBy = sortBy
        }
        await loadFirstPage()
    }

    func loadFirstPage() async {
        guard let gameId = currentGameId else { return }
        isLoading = true
        errorMessage = nil
        currentPage = 1

        let result = await modService.getModList(
            gameId: gameId,
            page: 1,
            keyword: modSearchKeyword.isEmpty ? nil : modSearchKeyword,
            sortBy: sortBy
        )

        handleModListResult(result, isLoadMore: false)
        isLoading = false
    }

    func loadNextPage() async {
        guard let gameId = currentGameId, currentPage < totalPages else { return }
        isLoadingMore = true

        let nextPage = currentPage + 1
        let result = await modService.getModList(
            gameId: gameId,
            page: nextPage,
            keyword: modSearchKeyword.isEmpty ? nil : modSearchKeyword,
            sortBy: sortBy
        )

        handleModListResult(result, isLoadMore: true)
        isLoadingMore = false
    }

    func loadPage(_ page: Int) async {
        guard let gameId = currentGameId, page >= 1, page <= totalPages else { return }
        isLoadingMore = true

        let result = await modService.getModList(
            gameId: gameId,
            page: page,
            keyword: modSearchKeyword.isEmpty ? nil : modSearchKeyword,
            sortBy: sortBy
        )

        handleModListResult(result, isLoadMore: false)
        isLoadingMore = false
    }

    func selectSort(_ sort: ModFilters.SortOption) async {
        sortBy = sort
        await loadFirstPage()
    }

    func searchMods(keyword: String) async {
        modSearchKeyword = keyword
        await loadFirstPage()
    }

    private func handleModListResult(_ result: Result<ModListResult, ModDownloaderError>, isLoadMore: Bool) {
        switch result {
        case .success(let listResult):
            if isLoadMore {
                mods.append(contentsOf: listResult.mods)
            } else {
                mods = listResult.mods
            }
            currentPage = listResult.currentPage
            totalPages = listResult.totalPages
            if mods.isEmpty {
                errorMessage = String(localized: "No Mods available")
            } else {
                errorMessage = nil
            }
        case .failure(let error):
            if !isLoadMore {
                mods = []
            }
            errorMessage = error.errorDescription
        }
    }
}
