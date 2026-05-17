//
//  CoreModuleTests.swift - GitHub iOS Core Module Test Framework
//  XCTest - Business logic, view models, utilities, integration tests
//

import XCTest
import Foundation
import CryptoKit
import UIKit

// MARK: - Test Constants
enum TestConstants {
    static let timeout: TimeInterval = 5.0
    static let networkTimeout: TimeInterval = 10.0
}

// MARK: - Test Error Enum
enum TestError: Error {
    case mockNotFound
    case setupFailed
    case assertionFailed
}

// MARK: - Mock Data Factory (Complete)
final class MockDataFactory {
    static func makeRepository(id: Int = 1, name: String = "TestRepo") -> Repository {
        return Repository(
            id: id,
            name: name,
            fullName: "owner/\(name)",
            description: "A test repository for iOS development",
            stars: 1000 + id,
            forks: 500 + id,
            language: "Swift"
        )
    }
    
    static func makeRepositories(count: Int) -> [Repository] {
        return (1...count).map { makeRepository(id: $0, name: "Repo-\($0)") }
    }
    
    static func makeUser(id: Int = 1, login: String = "testuser") -> User {
        return User(
            id: id,
            login: login,
            name: "Test User \(id)",
            bio: "iOS Developer passionate about Swift",
            followers: 1000 + id * 100,
            following: 500 + id * 50,
            avatarUrl: "https://avatars.githubusercontent.com/u/\(id)"
        )
    }
    
    static func makeIssue(id: Int = 1, number: Int = 42, state: String = "open") -> Issue {
        return Issue(
            id: id,
            number: number,
            title: "Test Issue #\(number)",
            body: "This is a test issue body with detailed description",
            state: state,
            createdAt: Date()
        )
    }
    
    static func makeJSONData<T: Encodable>(from object: T) -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return try! encoder.encode(object)
    }
    
    static func makeSearchResponse<T: Encodable>(items: [T]) -> Data {
        let wrapper = ["total_count": items.count, "incomplete_results": false, "items": items] as [String : Any]
        return try! JSONSerialization.data(withJSONObject: wrapper)
    }
}

// MARK: - Date Formatter Utility
class GitHubDateFormatter {
    static let shared = GitHubDateFormatter()
    private let isoFormatter: ISO8601DateFormatter
    private let displayFormatter: DateFormatter
    
    init() {
        isoFormatter = ISO8601DateFormatter()
        displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        displayFormatter.doesRelativeDateFormatting = true
    }
    
    func formatDate(_ date: Date) -> String {
        return displayFormatter.string(from: date)
    }
    
    func parseDate(from string: String) -> Date? {
        return isoFormatter.date(from: string)
    }
    
    func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Number Formatter Utility
class GitHubNumberFormatter {
    static let shared = GitHubNumberFormatter()
    private let numberFormatter: NumberFormatter
    
    init() {
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 1
    }
    
    func formatCount(_ count: Int) -> String {
        switch count {
        case 0..<1000:
            return "\(count)"
        case 1000..<1_000_000:
            let k = Double(count) / 1000.0
            return String(format: "%.1fK", k)
        default:
            let m = Double(count) / 1_000_000.0
            return String(format: "%.1fM", m)
        }
    }
}

// MARK: - Image Cache Utility
class ImageCache {
    static let shared = ImageCache()
    private let cache: NSCache<NSString, UIImage>
    
    init() {
        cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }
    
    func image(for key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func setImage(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func clear() {
        cache.removeAllObjects()
    }
}

// MARK: - Reachability Utility
class NetworkReachability {
    static let shared = NetworkReachability()
    
    var isConnected: Bool {
        // In real app, this would use NWPathMonitor
        return true
    }
    
    var isWiFi: Bool {
        return true
    }
}

// MARK: - Repository ViewModel
class RepositoryViewModel: Equatable {
    let repository: Repository
    
    var name: String { repository.name }
    var fullName: String { repository.fullName }
    var description: String? { repository.description }
    var stars: String { GitHubNumberFormatter.shared.formatCount(repository.stars) }
    var forks: String { GitHubNumberFormatter.shared.formatCount(repository.forks) }
    var language: String? { repository.language }
    
    var accessibilityLabel: String {
        var label = name
        if let description = description {
            label += ", \(description)"
        }
        label += ", \(stars) stars"
        if let language = language {
            label += ", written in \(language)"
        }
        return label
    }
    
    init(repository: Repository) {
        self.repository = repository
    }
    
    static func == (lhs: RepositoryViewModel, rhs: RepositoryViewModel) -> Bool {
        return lhs.repository == rhs.repository
    }
}

// MARK: - User ViewModel
class UserViewModel: Equatable {
    let user: User
    
    var name: String { user.name ?? user.login }
    var username: String { "@\(user.login)" }
    var bio: String? { user.bio }
    var followers: String { GitHubNumberFormatter.shared.formatCount(user.followers) }
    var following: String { GitHubNumberFormatter.shared.formatCount(user.following) }
    var avatarUrl: String { user.avatarUrl }
    
    var hasBio: Bool { user.bio != nil && !user.bio!.isEmpty }
    
    init(user: User) {
        self.user = user
    }
    
    static func == (lhs: UserViewModel, rhs: UserViewModel) -> Bool {
        return lhs.user == rhs.user
    }
}

// MARK: - Repository List Data Store
class RepositoryDataStore {
    private(set) var repositories: [Repository] = []
    private(set) var currentPage: Int = 1
    private(set) var isLoading: Bool = false
    private(set) var hasMorePages: Bool = true
    private(set) var totalCount: Int = 0
    
    var count: Int { repositories.count }
    var isEmpty: Bool { repositories.isEmpty }
    
    func repository(at index: Int) -> Repository? {
        guard index >= 0, index < repositories.count else { return nil }
        return repositories[index]
    }
    
    func viewModel(at index: Int) -> RepositoryViewModel? {
        guard let repo = repository(at: index) else { return nil }
        return RepositoryViewModel(repository: repo)
    }
    
    func append(repositories newRepositories: [Repository], total: Int) {
        repositories.append(contentsOf: newRepositories)
        totalCount = total
        hasMorePages = repositories.count < total
        currentPage += 1
        isLoading = false
    }
    
    func setLoading(_ loading: Bool) {
        isLoading = loading
    }
    
    func reset() {
        repositories.removeAll()
        currentPage = 1
        isLoading = false
        hasMorePages = true
        totalCount = 0
    }
}

// MARK: - Search History Manager
class SearchHistoryManager {
    private let userDefaults: UserDefaults
    private let maxHistoryCount = 10
    private let historyKey = "GitHubSearchHistory"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    var history: [String] {
        get { userDefaults.stringArray(forKey: historyKey) ?? [] }
        set { userDefaults.set(Array(newValue.prefix(maxHistoryCount)), forKey: historyKey) }
    }
    
    func addSearchQuery(_ query: String) {
        var currentHistory = history
        currentHistory.removeAll { $0.lowercased() == query.lowercased() }
        currentHistory.insert(query, at: 0)
        history = currentHistory
    }
    
    func clearHistory() {
        userDefaults.removeObject(forKey: historyKey)
    }
}

// MARK: - Theme Manager
enum AppTheme: Int {
    case system
    case light
    case dark
}

class ThemeManager {
    static let shared = ThemeManager()
    private let themeKey = "AppTheme"
    
    var currentTheme: AppTheme {
        get {
            let rawValue = UserDefaults.standard.integer(forKey: themeKey)
            return AppTheme(rawValue: rawValue) ?? .system
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: themeKey)
        }
    }
    
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch currentTheme {
        case .system: return .unspecified
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - Debouncer Utility
class Debouncer {
    private let delay: TimeInterval
    private var workItem: DispatchWorkItem?
    private let queue: DispatchQueue
    
    init(delay: TimeInterval, queue: DispatchQueue = .main) {
        self.delay = delay
        self.queue = queue
    }
    
    func debounce(_ block: @escaping () -> Void) {
        workItem?.cancel()
        let work = DispatchWorkItem(block: block)
        workItem = work
        queue.asyncAfter(deadline: .now() + delay, execute: work)
    }
    
    func cancel() {
        workItem?.cancel()
    }
    
    func invalidate() {
        workItem?.cancel()
        workItem = nil
    }
}

// MARK: - Throttler Utility
class Throttler {
    private let interval: TimeInterval
    private var lastExecution: Date = .distantPast
    private let queue: DispatchQueue
    
    init(interval: TimeInterval, queue: DispatchQueue = .main) {
        self.interval = interval
        self.queue = queue
    }
    
    func throttle(_ block: @escaping () -> Void) {
        let now = Date()
        if now.timeIntervalSince(lastExecution) >= interval {
            lastExecution = now
            queue.async(execute: block)
        }
    }
    
    func reset() {
        lastExecution = .distantPast
    }
}

// MARK: - XCTestCase Base Class
class GitHubTestCase: XCTestCase {
    var expectationTimeout: TimeInterval = TestConstants.timeout
    
    func waitForExpectations(file: StaticString = #file, line: UInt = #line) {
        waitForExpectations(timeout: expectationTimeout) { error in
            if let error = error {
                XCTFail("Expectation failed: \(error)", file: file, line: line)
            }
        }
    }
}

// MARK: - View Model Tests
class ViewModelTests: GitHubTestCase {
    
    // MARK: - RepositoryViewModel Tests
    func testRepositoryViewModel_DefaultValues() {
        // Arrange
        let repo = MockDataFactory.makeRepository(id: 1, name: "TestRepo")
        let viewModel = RepositoryViewModel(repository: repo)
        
        // Assert
        XCTAssertEqual(viewModel.name, "TestRepo")
        XCTAssertEqual(viewModel.fullName, "owner/TestRepo")
        XCTAssertEqual(viewModel.description, "A test repository for iOS development")
        XCTAssertEqual(viewModel.language, "Swift")
    }
    
    func testRepositoryViewModel_StarsFormatting() {
        // Arrange
        let testCases: [(Int, String)] = [
            (0, "0"),
            (999, "999"),
            (1000, "1.0K"),
            (1500, "1.5K"),
            (999999, "1000.0K"), // Wait, let me check - actually 999,999 is < 1M so it's 1000.0K
            (1_000_000, "1.0M"),
            (1_500_000, "1.5M")
        ]
        
        for (count, expected) in testCases {
            // Act
            let repo = Repository(
                id: 1, name: "Test", fullName: "owner/Test",
                description: nil, stars: count, forks: 0, language: nil
            )
            let viewModel = RepositoryViewModel(repository: repo)
            
            // Assert
            XCTAssertEqual(viewModel.stars, expected, "Failed for count: \(count)")
        }
    }
    
    func testRepositoryViewModel_ForksFormatting() {
        // Arrange
        let repo = Repository(
            id: 1, name: "Test", fullName: "owner/Test",
            description: nil, stars: 0, forks: 2500, language: nil
        )
        let viewModel = RepositoryViewModel(repository: repo)
        
        // Assert
        XCTAssertEqual(viewModel.forks, "2.5K")
    }
    
    func testRepositoryViewModel_AccessibilityLabel() {
        // Arrange - Full data
        let repo1 = MockDataFactory.makeRepository(id: 1)
        let viewModel1 = RepositoryViewModel(repository: repo1)
        
        // Assert
        XCTAssertTrue(viewModel1.accessibilityLabel.contains("TestRepo"))
        XCTAssertTrue(viewModel1.accessibilityLabel.contains("stars"))
        XCTAssertTrue(viewModel1.accessibilityLabel.contains("Swift"))
        
        // Arrange - No description, no language
        let repo2 = Repository(
            id: 2, name: "BareRepo", fullName: "owner/BareRepo",
            description: nil, stars: 100, forks: 50, language: nil
        )
        let viewModel2 = RepositoryViewModel(repository: repo2)
        
        // Assert
        XCTAssertEqual(viewModel2.accessibilityLabel, "BareRepo, 100 stars")
    }
    
    func testRepositoryViewModel_Equality() {
        // Arrange
        let repo1 = MockDataFactory.makeRepository(id: 1)
        let repo2 = MockDataFactory.makeRepository(id: 1)
        let repo3 = MockDataFactory.makeRepository(id: 2)
        
        let viewModel1 = RepositoryViewModel(repository: repo1)
        let viewModel2 = RepositoryViewModel(repository: repo2)
        let viewModel3 = RepositoryViewModel(repository: repo3)
        
        // Assert
        XCTAssertEqual(viewModel1, viewModel2)
        XCTAssertNotEqual(viewModel1, viewModel3)
    }
    
    // MARK: - UserViewModel Tests
    func testUserViewModel_DefaultValues() {
        // Arrange
        let user = MockDataFactory.makeUser(id: 1, login: "testuser")
        let viewModel = UserViewModel(user: user)
        
        // Assert
        XCTAssertEqual(viewModel.name, "Test User 1")
        XCTAssertEqual(viewModel.username, "@testuser")
        XCTAssertEqual(viewModel.bio, "iOS Developer passionate about Swift")
        XCTAssertEqual(viewModel.avatarUrl, "https://avatars.githubusercontent.com/u/1")
    }
    
    func testUserViewModel_NoNameFallsBackToLogin() {
        // Arrange
        let user = User(
            id: 1, login: "nouser", name: nil,
            bio: nil, followers: 0, following: 0,
            avatarUrl: "https://example.com"
        )
        let viewModel = UserViewModel(user: user)
        
        // Assert
        XCTAssertEqual(viewModel.name, "nouser")
    }
    
    func testUserViewModel_HasBio() {
        // Arrange
        let userWithBio = MockDataFactory.makeUser(id: 1)
        let viewModelWithBio = UserViewModel(user: userWithBio)
        
        let userNoBio = User(
            id: 2, login: "nobio", name: "No Bio",
            bio: nil, followers: 0, following: 0,
            avatarUrl: "https://example.com"
        )
        let viewModelNoBio = UserViewModel(user: userNoBio)
        
        // Assert
        XCTAssertTrue(viewModelWithBio.hasBio)
        XCTAssertFalse(viewModelNoBio.hasBio)
    }
    
    func testUserViewModel_FollowersFormatting() {
        // Arrange
        let user = MockDataFactory.makeUser(id: 1) // 1100 followers
        let viewModel = UserViewModel(user: user)
        
        // Assert
        XCTAssertEqual(viewModel.followers, "1.1K")
    }
    
    func testUserViewModel_Equality() {
        // Arrange
        let user1 = MockDataFactory.makeUser(id: 1)
        let user2 = MockDataFactory.makeUser(id: 1)
        let user3 = MockDataFactory.makeUser(id: 2)
        
        let viewModel1 = UserViewModel(user: user1)
        let viewModel2 = UserViewModel(user: user2)
        let viewModel3 = UserViewModel(user: user3)
        
        // Assert
        XCTAssertEqual(viewModel1, viewModel2)
        XCTAssertNotEqual(viewModel1, viewModel3)
    }
}

// MARK: - Data Store Tests
class DataStoreTests: GitHubTestCase {
    
    func testDataStore_InitialState() {
        // Arrange
        let store = RepositoryDataStore()
        
        // Assert
        XCTAssertTrue(store.isEmpty)
        XCTAssertEqual(store.count, 0)
        XCTAssertEqual(store.currentPage, 1)
        XCTAssertFalse(store.isLoading)
        XCTAssertTrue(store.hasMorePages)
        XCTAssertEqual(store.totalCount, 0)
    }
    
    func testDataStore_AppendRepositories() {
        // Arrange
        let store = RepositoryDataStore()
        let repos = MockDataFactory.makeRepositories(count: 10)
        
        // Act
        store.append(repositories: repos, total: 100)
        
        // Assert
        XCTAssertEqual(store.count, 10)
        XCTAssertEqual(store.totalCount, 100)
        XCTAssertEqual(store.currentPage, 2)
        XCTAssertTrue(store.hasMorePages)
        XCTAssertFalse(store.isLoading)
    }
    
    func testDataStore_RepositoryAtIndex() {
        // Arrange
        let store = RepositoryDataStore()
        let repos = MockDataFactory.makeRepositories(count: 5)
        store.append(repositories: repos, total: 5)
        
        // Act & Assert
        XCTAssertEqual(store.repository(at: 0)?.id, 1)
        XCTAssertEqual(store.repository(at: 4)?.id, 5)
        XCTAssertNil(store.repository(at: 5))
        XCTAssertNil(store.repository(at: -1))
    }
    
    func testDataStore_ViewModelAtIndex() {
        // Arrange
        let store = RepositoryDataStore()
        let repos = MockDataFactory.makeRepositories(count: 3)
        store.append(repositories: repos, total: 3)
        
        // Act
        let viewModel = store.viewModel(at: 1)
        
        // Assert
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel?.name, "Repo-2")
    }
    
    func testDataStore_SetLoading() {
        // Arrange
        let store = RepositoryDataStore()
        
        // Act
        store.setLoading(true)
        
        // Assert
        XCTAssertTrue(store.isLoading)
        
        // Act 2
        store.setLoading(false)
        
        // Assert 2
        XCTAssertFalse(store.isLoading)
    }
    
    func testDataStore_NoMorePages() {
        // Arrange
        let store = RepositoryDataStore()
        let repos = MockDataFactory.makeRepositories(count: 10)
        
        // Act
        store.append(repositories: repos, total: 10)
        
        // Assert
        XCTAssertFalse(store.hasMorePages)
    }
    
    func testDataStore_Reset() {
        // Arrange
        let store = RepositoryDataStore()
        let repos = MockDataFactory.makeRepositories(count: 10)
        store.append(repositories: repos, total: 100)
        store.setLoading(true)
        
        // Act
        store.reset()
        
        // Assert
        XCTAssertTrue(store.isEmpty)
        XCTAssertEqual(store.currentPage, 1)
        XCTAssertFalse(store.isLoading)
        XCTAssertTrue(store.hasMorePages)
        XCTAssertEqual(store.totalCount, 0)
    }
}

// MARK: - Utility Tests
class UtilityTests: GitHubTestCase {
    
    // MARK: - Number Formatter Tests
    func testNumberFormatter_Zero() {
        XCTAssertEqual(GitHubNumberFormatter.shared.formatCount(0), "0")
    }
    
    func testNumberFormatter_UnderThousand() {
        XCTAssertEqual(GitHubNumberFormatter.shared.formatCount(999), "999")
    }
    
    func testNumberFormatter_Thousands() {
        XCTAssertEqual(GitHubNumberFormatter.shared.formatCount(1000), "1.0K")
        XCTAssertEqual(GitHubNumberFormatter.shared.formatCount(1500), "1.5K")
        XCTAssertEqual(GitHubNumberFormatter.shared.formatCount(999999), "1000.0K")
    }
    
    func testNumberFormatter_Millions() {
        XCTAssertEqual(GitHubNumberFormatter.shared.formatCount(1_000_000), "1.0M")
        XCTAssertEqual(GitHubNumberFormatter.shared.formatCount(2_500_000), "2.5M")
    }
    
    // MARK: - Date Formatter Tests
    func testDateFormatter_ParseISO8601() {
        // Arrange
        let dateString = "2024-01-15T10:30:00Z"
        
        // Act
        let date = GitHubDateFormatter.shared.parseDate(from: dateString)
        
        // Assert
        XCTAssertNotNil(date)
    }
    
    func testDateFormatter_TimeAgo() {
        // Arrange
        let now = Date()
        let oneHourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: now)!
        
        // Act
        let timeAgo = GitHubDateFormatter.shared.timeAgo(from: oneHourAgo)
        
        // Assert - should contain "hour"
        XCTAssertTrue(timeAgo.contains("hour") || timeAgo.contains("minute"))
    }
    
    // MARK: - Image Cache Tests
    func testImageCache_SetAndGet() {
        // Arrange
        let cache = ImageCache.shared
        let image = UIImage()
        let key = "test-image-key"
        
        // Act
        cache.setImage(image, for: key)
        let retrieved = cache.image(for: key)
        
        // Assert
        XCTAssertNotNil(retrieved)
    }
    
    func testImageCache_CacheMiss() {
        // Arrange
        let cache = ImageCache.shared
        
        // Act
        let notFound = cache.image(for: "non-existent-key")
        
        // Assert
        XCTAssertNil(notFound)
    }
    
    func testImageCache_Clear() {
        // Arrange
        let cache = ImageCache.shared
        cache.setImage(UIImage(), for: "key1")
        cache.setImage(UIImage(), for: "key2")
        
        // Act
        cache.clear()
        
        // Assert
        XCTAssertNil(cache.image(for: "key1"))
        XCTAssertNil(cache.image(for: "key2"))
    }
    
    // MARK: - Search History Tests
    func testSearchHistory_AddQuery() {
        // Arrange
        let defaults = UserDefaults(suiteName: "TestDefaults")!
        let manager = SearchHistoryManager(userDefaults: defaults)
        manager.clearHistory()
        
        // Act
        manager.addSearchQuery("swift")
        manager.addSearchQuery("objective-c")
        
        // Assert
        XCTAssertEqual(manager.history.count, 2)
        XCTAssertEqual(manager.history[0], "objective-c") // Most recent first
        XCTAssertEqual(manager.history[1], "swift")
        
        // Cleanup
        defaults.removeSuite(named: "TestDefaults")
    }
    
    func testSearchHistory_DuplicatesRemoved() {
        // Arrange
        let defaults = UserDefaults(suiteName: "TestDefaults")!
        let manager = SearchHistoryManager(userDefaults: defaults)
        manager.clearHistory()
        
        // Act
        manager.addSearchQuery("swift")
        manager.addSearchQuery("SWIFT") // Different case
        manager.addSearchQuery("Swift") // Different case
        
        // Assert
        XCTAssertEqual(manager.history.count, 1)
        
        // Cleanup
        defaults.removeSuite(named: "TestDefaults")
    }
    
    func testSearchHistory_LimitTo10() {
        // Arrange
        let defaults = UserDefaults(suiteName: "TestDefaults")!
        let manager = SearchHistoryManager(userDefaults: defaults)
        manager.clearHistory()
        
        // Act
        for i in 1...15 {
            manager.addSearchQuery("query-\(i)")
        }
        
        // Assert
        XCTAssertEqual(manager.history.count, 10)
        XCTAssertEqual(manager.history.first, "query-15") // Most recent
        
        // Cleanup
        defaults.removeSuite(named: "TestDefaults")
    }
    
    func testSearchHistory_Clear() {
        // Arrange
        let defaults = UserDefaults(suiteName: "TestDefaults")!
        let manager = SearchHistoryManager(userDefaults: defaults)
        manager.addSearchQuery("swift")
        
        // Act
        manager.clearHistory()
        
        // Assert
        XCTAssertTrue(manager.history.isEmpty)
        
        // Cleanup
        defaults.removeSuite(named: "TestDefaults")
    }
    
    // MARK: - Theme Manager Tests
    func testThemeManager_DefaultsToSystem() {
        // Arrange
        let defaults = UserDefaults(suiteName: "ThemeDefaults")!
        defaults.removeObject(forKey: "AppTheme")
        
        // Act
        let theme = ThemeManager.shared.currentTheme
        
        // Assert
        XCTAssertEqual(theme, .system)
    }
    
    func testThemeManager_UserInterfaceStyleMapping() {
        // Assert
        XCTAssertEqual(ThemeManager.shared.userInterfaceStyle, .unspecified)
    }
    
    // MARK: - Debouncer Tests
    func testDebouncer_DebouncesCorrectly() {
        // Arrange
        let expectation = self.expectation(description: "Debouncer fired")
        let debouncer = Debouncer(delay: 0.1)
        var callCount = 0
        
        // Act
        for _ in 1...5 {
            debouncer.debounce {
                callCount += 1
                expectation.fulfill()
            }
        }
        
        // Assert
        waitForExpectations()
        XCTAssertEqual(callCount, 1) // Only last call should fire
    }
    
    func testDebouncer_Cancel() {
        // Arrange
        let debouncer = Debouncer(delay: 0.1)
        var didFire = false
        
        // Act
        debouncer.debounce {
            didFire = true
        }
        debouncer.cancel()
        
        // Wait and assert
        let expectation = self.expectation(description: "Wait for debounce")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        waitForExpectations()
        
        XCTAssertFalse(didFire)
    }
    
    // MARK: - Throttler Tests
    func testThrottler_ThrottlesCorrectly() {
        // Arrange
        let throttler = Throttler(interval: 0.1)
        var callCount = 0
        
        // Act - call 5 times within interval
        for _ in 1...5 {
            throttler.throttle {
                callCount += 1
            }
        }
        
        // Wait
        let expectation = self.expectation(description: "Wait for throttle")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            expectation.fulfill()
        }
        waitForExpectations()
        
        // Assert - only first call should have fired
        XCTAssertEqual(callCount, 1)
    }
    
    func testThrottler_Reset() {
        // Arrange
        let throttler = Throttler(interval: 1.0)
        var callCount = 0
        
        // First call
        throttler.throttle { callCount += 1 }
        
        // Reset
        throttler.reset()
        
        // Second call after reset
        throttler.throttle { callCount += 1 }
        
        // Assert
        XCTAssertEqual(callCount, 2)
    }
}

// MARK: - Integration Tests
class IntegrationTests: GitHubTestCase {
    
    func testRepositoryViewModel_IntegrationWithDataStore() {
        // Arrange
        let store = RepositoryDataStore()
        let repos = MockDataFactory.makeRepositories(count: 3)
        store.append(repositories: repos, total: 3)
        
        // Act
        let viewModel = store.viewModel(at: 0)
        
        // Assert
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel?.name, "Repo-1")
        XCTAssertEqual(viewModel?.stars, "1.0K")
    }
    
    func testSearchHistory_IntegrationWithViewModelLayer() {
        // Arrange
        let defaults = UserDefaults(suiteName: "IntegrationDefaults")!
        let manager = SearchHistoryManager(userDefaults: defaults)
        manager.clearHistory()
        
        // Simulate user performing searches
        let searchQueries = ["swiftui", "combine", "async await"]
        for query in searchQueries {
            manager.addSearchQuery(query)
        }
        
        // Assert - history should be in reverse order of insertion
        XCTAssertEqual(manager.history, ["async await", "combine", "swiftui"])
        
        // Cleanup
        defaults.removeSuite(named: "IntegrationDefaults")
    }
    
    func testImageCache_IntegrationWithViewModel() {
        // Arrange
        let cache = ImageCache.shared
        let user = MockDataFactory.makeUser(id: 1)
        let viewModel = UserViewModel(user: user)
        
        // Act - simulate loading and caching image
        let testImage = UIImage()
        cache.setImage(testImage, for: viewModel.avatarUrl)
        
        // Assert
        XCTAssertNotNil(cache.image(for: viewModel.avatarUrl))
    }
}

// MARK: - Performance Tests
class PerformanceTests: XCTestCase {
    
    func testNumberFormatter_Performance() {
        measure {
            for i in 0..<1000 {
                _ = GitHubNumberFormatter.shared.formatCount(i)
            }
        }
    }
    
    func testViewModelCreation_Performance() {
        let repos = MockDataFactory.makeRepositories(count: 100)
        
        measure {
            for repo in repos {
                _ = RepositoryViewModel(repository: repo)
            }
        }
    }
    
    func testDataStoreAppend_Performance() {
        let repos = MockDataFactory.makeRepositories(count: 1000)
        
        measure {
            let store = RepositoryDataStore()
            store.append(repositories: repos, total: 1000)
        }
    }
}

// MARK: - Test Observation (for CI/CD integration)
class TestObserver: NSObject, XCTestObservation {
    
    static func register() {
        let observer = TestObserver()
        XCTestObservationCenter.shared.addTestObserver(observer)
    }
    
    func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
        print("❌ TEST FAILED: \(testCase.name) - \(description) at \(filePath ?? "unknown"):\(lineNumber)")
    }
    
    func testCaseDidFinish(_ testCase: XCTestCase) {
        print("✅ TEST COMPLETED: \(testCase.name)")
    }
    
    func testBundleDidFinish(_ testBundle: Bundle) {
        print("📊 All tests completed in bundle: \(testBundle.bundlePath)")
    }
}

// MARK: - Test Result Summary
struct TestResult {
    let name: String
    let success: Bool
    let duration: TimeInterval
    let message: String?
}

class TestSummary {
    private var results: [TestResult] = []
    
    func addResult(_ result: TestResult) {
        results.append(result)
    }
    
    var totalTests: Int { results.count }
    var passedTests: Int { results.filter { $0.success }.count }
    var failedTests: Int { results.filter { !$0.success }.count }
    var successRate: Double { Double(passedTests) / Double(totalTests) * 100 }
    
    func generateReport() -> String {
        return """
        📊 TEST REPORT
        ==================================
        Total Tests: \(totalTests)
        Passed: \(passedTests) ✅
        Failed: \(failedTests) ❌
        Success Rate: \(String(format: "%.1f%%", successRate))
        ==================================
        """
    }
}

// MARK: - Mock Network Testing Support
class MockNetworkProtocol: URLProtocol {
    static var mockResponses: [URL: (Data, HTTPURLResponse)] = [:]
    
    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url else { return false }
        return mockResponses[url] != nil

    }
}
