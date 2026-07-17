import Foundation

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchKeyword: String = ""
    @Published var games: [Game] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var errorMessage: String?
    @Published var hasMoreResults: Bool = false
    @Published var totalCount: Int = 0
    @Published var currentPage: Int = 1

    private let searchService: SearchService

    init(searchService: SearchService) {
        self.searchService = searchService
    }

    func search() async {
        let keyword = searchKeyword.trimmingCharacters(in: .whitespaces)
        guard !keyword.isEmpty else {
            errorMessage = String(localized: "Please enter search keyword")
            return
        }

        isLoading = true
        errorMessage = nil
        currentPage = 1

        let result = await searchService.searchGames(keyword: keyword, page: 1)

        switch result {
        case .success(let searchResult):
            self.games = searchResult.games
            self.hasMoreResults = searchResult.hasMore
            self.totalCount = searchResult.totalCount
            if searchResult.games.isEmpty {
                errorMessage = String(localized: "No matching games found")
            }
        case .failure(let error):
            self.games = []
            self.errorMessage = error.errorDescription
        }

        isLoading = false
    }

    func loadMoreGames() async {
        guard !isLoadingMore && hasMoreResults else { return }
        let keyword = searchKeyword.trimmingCharacters(in: .whitespaces)
        guard !keyword.isEmpty else { return }

        isLoadingMore = true
        currentPage += 1

        let result = await searchService.searchGames(keyword: keyword, page: currentPage)

        switch result {
        case .success(let searchResult):
            var existing = Set(games.map(\.gamebananaID))
            for game in searchResult.games {
                if !existing.contains(game.gamebananaID) {
                    existing.insert(game.gamebananaID)
                    self.games.append(game)
                }
            }
            self.hasMoreResults = searchResult.hasMore
        case .failure:
            currentPage -= 1
        }

        isLoadingMore = false
    }

    func clearSearch() {
        searchKeyword = ""
        games = []
        errorMessage = nil
        hasMoreResults = false
        totalCount = 0
        currentPage = 1
    }
}
