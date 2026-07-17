import Foundation
@testable import SwitchModDownloader

final class MockHTTPClient: HTTPClientProtocol, @unchecked Sendable {
    var getHandler: (@Sendable (URL, [String: String]?) async throws -> Data)?
    var downloadHandler: (@Sendable (URL, URL) async throws -> URL)?

    func get<T: Codable>(url: URL, params: [String: String]?) async throws -> T {
        guard let handler = getHandler else {
            throw ModDownloaderError.invalidResponse
        }
        let data = try await handler(url, params)
        return try JSONDecoder().decode(T.self, from: data)
    }

    func download(url: URL, to destination: URL) async throws -> URL {
        guard let handler = downloadHandler else {
            throw ModDownloaderError.downloadFailed(underlying: NSError(domain: "test", code: -1))
        }
        return try await handler(url, destination)
    }
}

@main
struct TestRunner {
    static func main() async {
        var passed = 0
        var failed = 0

        print("═══ Running Tests ═══\n")

        do {
            print("── GameBanana Response Tests ──")
            try testGameRecordToGame()
            try testModRecordWithStats()
            try testModRecordMissingStats()
            try testFileRecordToFile()
            try testModListResponsePagination()
            try testFileDetailRomfsDetection()
            try testFileDetailNoRomfs()
            try testFileDetailExefsPatches()
            try testGameDetailWithCategories()
            passed += 1
        } catch { print("  ✗ FAILED: \(error)"); failed += 1 }

        do {
            print("── Business Model Tests ──")
            try testFileFormattedSize()
            try testDownloadProgressCalculation()
            try testDownloadProgressZeroTotal()
            try testDownloadProgressRemainingTime()
            try testModListResultHasNextPage()
            try testDataSourceFeaturesOptionSet()
            try testAppLanguageLocaleIdentifiers()
            try testAppConfigurationDefaults()
            try testSearchModeCases()
            passed += 1
        } catch { print("  ✗ FAILED: \(error)"); failed += 1 }

        do {
            print("── RetryPolicy Tests ──")
            try await testRetrySuccessFirstAttempt()
            try await testRetryRetryThenSucceed()
            try await testRetryThrowsAfterMaxRetries()
            passed += 1
        } catch { print("  ✗ FAILED: \(error)"); failed += 1 }

        do {
            print("── GameBananaDataSource Tests ──")
            try await testSearchGamesEndpoint()
            try await testSearchByTitleIdEndpoint()
            try await testGetModListEndpoint()
            try await testGetModListWithCategory()
            try await testSupportedFeatures()
            passed += 1
        } catch { print("  ✗ FAILED: \(error)"); failed += 1 }

        do {
            print("── ConfigurationStore Tests ──")
            try testConfigurationRoundTrip()
            try testConfigurationReset()
            try testConfigurationDefaultsOnEmpty()
            passed += 1
        } catch { print("  ✗ FAILED: \(error)"); failed += 1 }

        print("\n═══ Results: \(passed) passed, \(failed) failed ═══")
        exit(failed > 0 ? 1 : 0)
    }
}

extension TestRunner {
    static func testGameRecordToGame() throws {
        let json = """
        {"_idRow":123,"_sName":"Zelda (Switch)","_sBannerUrl":"https://img.test/banner.jpg","_aPreviewMedia":null}
        """
        let record = try JSONDecoder().decode(GameBananaGameRecord.self, from: json.data(using: .utf8)!)
        let game = record.toGame()
        assert(game.id == 123, "id mismatch")
        assert(game.title == "Zelda (Switch)", "title mismatch")
        assert(game.bannerURL != nil, "bannerURL should not be nil")
        print("  ✓ testGameRecordToGame")
    }

    static func testModRecordWithStats() throws {
        let json = """
        {"_idRow":789,"_sName":"HD Mod","_aSubmitter":{"_sName":"Author"},"_idGame":123,"_nDownloadCount":1500,"_nCommentCount":42,"_nViewCount":10000,"_nLikeCount":200,"_aPreviewMedia":null,"_aFiles":null}
        """
        let record = try JSONDecoder().decode(GameBananaModRecord.self, from: json.data(using: .utf8)!)
        let mod = record.toMod()
        assert(mod.downloadCount == 1500, "downloadCount mismatch")
        assert(mod.commentCount == 42, "commentCount mismatch")
        assert(mod.author == "Author", "author mismatch")
        print("  ✓ testModRecordWithStats")
    }

    static func testModRecordMissingStats() throws {
        let json = """
        {"_idRow":100,"_sName":"Simple Mod","_idGame":50}
        """
        let record = try JSONDecoder().decode(GameBananaModRecord.self, from: json.data(using: .utf8)!)
        let mod = record.toMod()
        assert(mod.downloadCount == nil, "downloadCount should be nil")
        assert(mod.commentCount == nil, "commentCount should be nil")
        print("  ✓ testModRecordMissingStats")
    }

    static func testFileRecordToFile() throws {
        let json = """
        {"_idRow":555,"_sFile":"mod.zip","_nFilesize":10485760,"_sDownloadUrl":"https://gamebanana.com/dl/555","_tsDateAdded":1700000000.0}
        """
        let record = try JSONDecoder().decode(GameBananaFileRecord.self, from: json.data(using: .utf8)!)
        let file = record.toFile()
        assert(file.size == 10485760, "size mismatch")
        assert(file.romfs == nil, "romfs should be nil")
        print("  ✓ testFileRecordToFile")
    }

    static func testModListResponsePagination() throws {
        let json = """
        {"_aRecords":[],"_nPageCount":5,"_nRecordCount":200,"_nPerpage":50}
        """
        let response = try JSONDecoder().decode(GameBananaModListResponse.self, from: json.data(using: .utf8)!)
        assert(response.totalPages == 5, "totalPages mismatch")
        assert(response.totalCount == 200, "totalCount mismatch")
        print("  ✓ testModListResponsePagination")
    }

    static func testFileDetailRomfsDetection() throws {
        let json = """
        {"_idRow":999,"_sFile":"mod.zip","_nFilesize":5000000,"_sDownloadUrl":"https://gamebanana.com/dl/999","_aArchiveFileTree":{"_aChildren":[{"_sName":"romfs","_aChildren":null}]}}
        """
        let response = try JSONDecoder().decode(GameBananaFileDetailResponse.self, from: json.data(using: .utf8)!)
        assert(response.hasRomfs == true, "should detect romfs")
        print("  ✓ testFileDetailRomfsDetection")
    }

    static func testFileDetailNoRomfs() throws {
        let json = """
        {"_idRow":998,"_sFile":"mod.zip","_nFilesize":3000000,"_sDownloadUrl":"https://gamebanana.com/dl/998","_aArchiveFileTree":{"_aChildren":[{"_sName":"readme.txt","_aChildren":null}]}}
        """
        let response = try JSONDecoder().decode(GameBananaFileDetailResponse.self, from: json.data(using: .utf8)!)
        assert(response.hasRomfs == false, "should not detect romfs")
        print("  ✓ testFileDetailNoRomfs")
    }

    static func testFileDetailExefsPatches() throws {
        let json = """
        {"_idRow":997,"_sFile":"patch.zip","_nFilesize":1000000,"_sDownloadUrl":"https://gamebanana.com/dl/997","_aArchiveFileTree":{"_aChildren":[{"_sName":"exefs_patches","_aChildren":[{"_sName":"patch.bin","_aChildren":null}]}]}}
        """
        let response = try JSONDecoder().decode(GameBananaFileDetailResponse.self, from: json.data(using: .utf8)!)
        assert(response.hasRomfs == true, "should detect exefs_patches")
        print("  ✓ testFileDetailExefsPatches")
    }

    static func testGameDetailWithCategories() throws {
        let json = """
        {"_sName":"Zelda BOTW","_idRow":123,"_aPreviewMedia":null,"_aModRootCategories":[{"_sName":"Skins","_idRow":10},{"_sName":"Maps","_idRow":20}]}
        """
        let response = try JSONDecoder().decode(GameBananaGameDetailResponse.self, from: json.data(using: .utf8)!)
        let game = response.toGame()
        assert(game.categories?.count == 2, "categories count mismatch")
        assert(game.categories?[0].name == "Skins", "category name mismatch")
        print("  ✓ testGameDetailWithCategories")
    }
}

extension TestRunner {
    static func testFileFormattedSize() throws {
        let file = File(id: 1, name: "test.zip", fileID: 1, size: 15_728_640, url: URL(string: "https://example.com/f")!, date: nil, romfs: nil)
        assert(file.formattedSize.contains("MB"), "should contain MB")
        print("  ✓ testFileFormattedSize")
    }

    static func testDownloadProgressCalculation() throws {
        let p = DownloadProgress(taskId: "t", bytesWritten: 50, totalBytes: 100, speed: 1024, remainingTime: 60)
        assert(p.progress == 0.5, "progress should be 0.5")
        print("  ✓ testDownloadProgressCalculation")
    }

    static func testDownloadProgressZeroTotal() throws {
        let p = DownloadProgress(taskId: "t", bytesWritten: 0, totalBytes: 0, speed: 0, remainingTime: nil)
        assert(p.progress == 0, "progress should be 0")
        print("  ✓ testDownloadProgressZeroTotal")
    }

    static func testDownloadProgressRemainingTime() throws {
        let p = DownloadProgress(taskId: "t", bytesWritten: 1000, totalBytes: 10000, speed: 100, remainingTime: 125)
        assert(p.formattedRemainingTime == "2:05", "remaining time format mismatch")
        print("  ✓ testDownloadProgressRemainingTime")
    }

    static func testModListResultHasNextPage() throws {
        let r1 = ModListResult(mods: [], currentPage: 1, totalPages: 5, perPage: 50, totalCount: 200)
        assert(r1.hasNextPage == true)
        let r2 = ModListResult(mods: [], currentPage: 5, totalPages: 5, perPage: 50, totalCount: 200)
        assert(r2.hasNextPage == false)
        print("  ✓ testModListResultHasNextPage")
    }

    static func testDataSourceFeaturesOptionSet() throws {
        let f: DataSourceFeatures = [.gameSearch, .titleIdSearch, .statistics]
        assert(f.contains(.gameSearch))
        assert(!f.contains(.categoryFilter))
        print("  ✓ testDataSourceFeaturesOptionSet")
    }

    static func testAppLanguageLocaleIdentifiers() throws {
        assert(AppLanguage.chinese.localeIdentifier == "zh_CN")
        assert(AppLanguage.english.localeIdentifier == "en_US")
        print("  ✓ testAppLanguageLocaleIdentifiers")
    }

    static func testAppConfigurationDefaults() throws {
        let c = AppConfiguration.default
        assert(c.language == .system)
        assert(c.pageSize == 50)
        assert(c.activeDataSource == "com.gamebanana")
        print("  ✓ testAppConfigurationDefaults")
    }

    static func testSearchModeCases() throws {
        assert(SearchMode.allCases.count == 2)
        print("  ✓ testSearchModeCases")
    }
}

extension TestRunner {
    static func testRetrySuccessFirstAttempt() async throws {
        var count = 0
        let result = try await RetryPolicy.execute { count += 1; return 42 }
        assert(result == 42)
        assert(count == 1)
        print("  ✓ testRetrySuccessFirstAttempt")
    }

    static func testRetryRetryThenSucceed() async throws {
        var count = 0
        let result = try await RetryPolicy.execute {
            count += 1
            if count < 3 { throw NSError(domain: "test", code: -1) }
            return "ok"
        }
        assert(result == "ok")
        assert(count == 3)
        print("  ✓ testRetryRetryThenSucceed")
    }

    static func testRetryThrowsAfterMaxRetries() async throws {
        var count = 0
        do {
            _ = try await RetryPolicy.execute {
                count += 1
                throw ModDownloaderError.networkError(underlying: NSError(domain: "t", code: -1))
            }
            assertionFailure("should throw")
        } catch {
            assert(count == 3)
        }
        print("  ✓ testRetryThrowsAfterMaxRetries")
    }
}

extension TestRunner {
    static func testSearchGamesEndpoint() async throws {
        let mock = MockHTTPClient()
        var capturedURL: URL?
        var capturedParams: [String: String]?
        mock.getHandler = { url, params in
            capturedURL = url; capturedParams = params
            return "{ \"_aMetadata\": null, \"_aRecords\": [] }".data(using: .utf8)!
        }
        let ds = GameBananaDataSource(httpClient: mock)
        _ = try await ds.searchGames(keyword: "Zelda")
        assert(capturedURL!.absoluteString.contains("Search/Results"))
        assert(capturedParams?["_sSearchString"] == "Zelda")
        print("  ✓ testSearchGamesEndpoint")
    }

    static func testSearchByTitleIdEndpoint() async throws {
        let mock = MockHTTPClient()
        var capturedURL: URL?
        mock.getHandler = { url, _ in
            capturedURL = url
            return "{ \"_aMetadata\": null, \"_aRecords\": [] }".data(using: .utf8)!
        }
        let ds = GameBananaDataSource(httpClient: mock)
        _ = try await ds.searchGameByTitleId("0100000000010000")
        assert(capturedURL!.absoluteString.contains("NameMatch"))
        print("  ✓ testSearchByTitleIdEndpoint")
    }

    static func testGetModListEndpoint() async throws {
        let mock = MockHTTPClient()
        var capturedURL: URL?
        var capturedParams: [String: String]?
        mock.getHandler = { url, params in
            capturedURL = url; capturedParams = params
            return "{ \"_aRecords\": [], \"_nPageCount\": 1, \"_nRecordCount\": 0, \"_nPerpage\": 50 }".data(using: .utf8)!
        }
        let ds = GameBananaDataSource(httpClient: mock)
        _ = try await ds.getModList(gameId: 123, page: 2, filters: nil)
        assert(capturedURL!.absoluteString.contains("Game/123/Subfeed"))
        assert(capturedParams?["_nPage"] == "2")
        print("  ✓ testGetModListEndpoint")
    }

    static func testGetModListWithCategory() async throws {
        let mock = MockHTTPClient()
        var capturedURL: URL?
        mock.getHandler = { url, _ in
            capturedURL = url
            return "{ \"_aRecords\": [], \"_nPageCount\": 1, \"_nRecordCount\": 0, \"_nPerpage\": 15 }".data(using: .utf8)!
        }
        let ds = GameBananaDataSource(httpClient: mock)
        let filters = ModFilters(categoryId: 42, keyword: nil, sortBy: nil)
        _ = try await ds.getModList(gameId: 123, page: 1, filters: filters)
        assert(capturedURL!.absoluteString.contains("Mod/Index"))
        print("  ✓ testGetModListWithCategory")
    }

    static func testSupportedFeatures() async throws {
        let mock = MockHTTPClient()
        let ds = GameBananaDataSource(httpClient: mock)
        assert(ds.supportedFeatures.contains(.gameSearch))
        assert(ds.supportedFeatures.contains(.statistics))
        print("  ✓ testSupportedFeatures")
    }
}

extension TestRunner {
    static func testConfigurationRoundTrip() throws {
        let store = ConfigurationStore()
        var config = AppConfiguration.default
        config.language = .chinese
        config.pageSize = 30
        store.save(config)
        let loaded = store.load()
        assert(loaded.language == .chinese)
        assert(loaded.pageSize == 30)
        store.reset()
        print("  ✓ testConfigurationRoundTrip")
    }

    static func testConfigurationReset() throws {
        let store = ConfigurationStore()
        var config = AppConfiguration.default
        config.language = .english
        store.save(config)
        store.reset()
        let loaded = store.load()
        assert(loaded.language == .system)
        print("  ✓ testConfigurationReset")
    }

    static func testConfigurationDefaultsOnEmpty() throws {
        let store = ConfigurationStore()
        store.reset()
        let loaded = store.load()
        assert(loaded.language == .system)
        assert(loaded.pageSize == 50)
        print("  ✓ testConfigurationDefaultsOnEmpty")
    }
}
