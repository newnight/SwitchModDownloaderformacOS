import Foundation

@MainActor
class ModDetailViewModel: ObservableObject {
    @Published var mod: Mod?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedImageIndex: Int = 0

    private let modService: ModService
    private var currentModId: Int?

    init(modService: ModService) {
        self.modService = modService
    }

    func loadModDetail(modId: Int) async {
        guard !isLoading else { return }
        currentModId = modId
        isLoading = true
        errorMessage = nil
        mod = nil

        let result = await modService.getModDetail(modId: modId)

        switch result {
        case .success(let mod):
            self.mod = mod
        case .failure(let error):
            self.errorMessage = error.errorDescription
        }

        isLoading = false
    }

    func retry() async {
        guard let modId = currentModId else { return }
        isLoading = true
        errorMessage = nil
        mod = nil

        let result = await modService.getModDetail(modId: modId)

        switch result {
        case .success(let mod):
            self.mod = mod
        case .failure(let error):
            self.errorMessage = error.errorDescription
        }

        isLoading = false
    }

    var formattedDescription: String? {
        guard let desc = mod?.description else { return nil }
        return stripHTMLTags(from: desc)
    }

    private func stripHTMLTags(from html: String) -> String {
        var result = html
        result = result.replacingOccurrences(of: "<br[^>]*>", with: "\n", options: .regularExpression, range: nil)
        result = result.replacingOccurrences(of: "<p>", with: "\n", options: .regularExpression, range: nil)
        result = result.replacingOccurrences(of: "</p>", with: "\n", options: .regularExpression, range: nil)
        result = result.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        result = result.replacingOccurrences(of: "&nbsp;", with: " ")
        result = result.replacingOccurrences(of: "&amp;", with: "&")
        result = result.replacingOccurrences(of: "&lt;", with: "<")
        result = result.replacingOccurrences(of: "&gt;", with: ">")
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
