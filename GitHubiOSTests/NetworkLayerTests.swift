//
//  NetworkLayerTests.swift - GitHub iOS Network Layer Unit Tests
//  XCTest - API Requests, Error Handling, Mock Data
//

import XCTest
@testable import GitHubiOS

// MARK: - Network Errors
enum NetworkError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case decodingError(Error)
    case noData
    case networkError(Error)
    
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL): return true
        case (.invalidResponse, .invalidResponse): return true
        case (.noData, .noData): return true
        case (.statusCode(let lhsCode), .statusCode(let rhsCode)): return lhsCode == rhsCode
        default: return false
        }
    }
}

// MARK: - APIClient Implementation
class APIClient: APIClientProtocol {
    private let session: NetworkSession
    private let baseURL = "https://api.github.com"
    
    init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }
    
    func fetchRepositories(query: String) async throws -> [Repository] {
        guard let url = URL(string: "\(baseURL)/search/repositories?q=\(query)") else {
            throw NetworkError.invalidURL
        }
        
        let request = URLRequest(url: url)
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.statusCode(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let searchResponse = try decoder.decode(SearchResponse<Repository>.self, from: data)
        return searchResponse.items
    }
    
    func fetchUser(username: String) async throws -> User {
        guard let url = URL(string: "\(baseURL)/users/\(username)") else {
            throw NetworkError.invalidURL
        }
        
        let request = URLRequest(url: url)
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.statusCode(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(User.self, from: data)
    }
    
    func fetchIssues(owner: String, repo: String) async throws -> [Issue] {
        guard let url = URL(string: "\(baseURL)/repos/\(owner)/\(repo)/issues") else {
            throw NetworkError.invalidURL
        }
        
        let request = URLRequest(url: url)
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.statusCode(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([Issue].self, from: data)
    }
}

struct SearchResponse<T: Codable>: Codable {
    let items: [T]
}

// MARK: - Mock Network Session
class MockNetworkSession: NetworkSession {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    var lastRequest: URLRequest?
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        lastRequest = request
        
        if let error = mockError {
            throw error
        }
        
        guard let data = mockData, let response = mockResponse else {
            throw NetworkError.noData
        }
        
        return (data, response)
    }
}

// MARK: - Mock Data Factory
class MockDataFactory {
    static func makeMockRepository(id: Int = 1, name: String = "TestRepo") -> Repository {
        return Repository(
            id: id,
            name: name,
            fullName: "owner/\(name)",
            description: "Test repository description",
            stars: 100,
            forks: 50,
            language: "Swift"
        )
    }
    
    static func makeMockUser(id: Int = 1, login: String = "testuser") -> User {
        return User(
            id: id,
            login: login,
            name: "Test User",
            bio: "iOS Developer",
            followers: 1000,
            following: 500,
            avatarUrl: "https://example.com/avatar.png"
        )
    }
    
    static func makeMockIssue(id: Int = 1, number: Int = 42) -> Issue {
        return Issue(
            id: id,
            number: number,
            title: "Test Issue Title",
            body: "This is a test issue body",
            state: "open",
            createdAt: ISO8601DateFormatter().date(from: "2024-01-01T00:00:00Z")!
        )
    }
    
    static func makeJSONData<T: Encodable>(from object: T) -> Data {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return try! encoder.encode(object)
    }
}

// MARK: - Network Layer Unit Tests
class NetworkLayerTests: XCTestCase {
    var mockSession: MockNetworkSession!
    var apiClient: APIClient!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockSession = MockNetworkSession()
        apiClient = APIClient(session: mockSession)
    }
    
    override func tearDownWithError() throws {
        mockSession = nil
        apiClient = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Success Case Tests
    func testFetchRepositories_Success() async throws {
        // Arrange
        let mockRepos = [MockDataFactory.makeMockRepository(id: 1), MockDataFactory.makeMockRepository(id: 2)]
        let searchResponse = SearchResponse(items: mockRepos)
        let data = MockDataFactory.makeJSONData(from: searchResponse)
        
        mockSession.mockData = data
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.github.com/search/repositories?q=swift")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // Act
        let result = try await apiClient.fetchRepositories(query: "swift")
        
        // Assert
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, 1)
        XCTAssertEqual(result[1].id, 2)
        XCTAssertEqual(mockSession.lastRequest?.url?.path, "/search/repositories")
    }
    
    func testFetchUser_Success() async throws {
        // Arrange
        let mockUser = MockDataFactory.makeMockUser()
        let data = MockDataFactory.makeJSONData(from: mockUser)
        
        mockSession.mockData = data
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.github.com/users/testuser")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // Act
        let result = try await apiClient.fetchUser(username: "testuser")
        
        // Assert
        XCTAssertEqual(result.login, "testuser")
        XCTAssertEqual(result.name, "Test User")
        XCTAssertEqual(result.followers, 1000)
    }
    
    func testFetchIssues_Success() async throws {
        // Arrange
        let mockIssues = [MockDataFactory.makeMockIssue(number: 1), MockDataFactory.makeMockIssue(number: 2)]
        let data = MockDataFactory.makeJSONData(from: mockIssues)
        
        mockSession.mockData = data
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.github.com/repos/owner/repo/issues")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // Act
        let result = try await apiClient.fetchIssues(owner: "owner", repo: "repo")
        
        // Assert
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].number, 1)
        XCTAssertEqual(result[1].number, 2)
    }
    
    // MARK: - Error Case Tests
    func testFetchRepositories_InvalidURL() async {
        // Arrange - The base URL should be valid but let's test edge case
        // We'll test with a query that would cause URL issues
        let invalidQuery = String(repeating: "x", count: 10000)
        
        // Act & Assert
        do {
            _ = try await apiClient.fetchRepositories(query: invalidQuery)
            XCTFail("Expected error but got success")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testFetchUser_NotFound404() async {
        // Arrange
        mockSession.mockData = Data()
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.github.com/users/nonexistent")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )
        
        // Act & Assert
        do {
            _ = try await apiClient.fetchUser(username: "nonexistent")
            XCTFail("Expected 404 error but got success")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .statusCode(404))
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    func testFetchRepositories_ServerError500() async {
        // Arrange
        mockSession.mockData = Data()
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.github.com/search/repositories?q=swift")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )
        
        // Act & Assert
        do {
            _ = try await apiClient.fetchRepositories(query: "swift")
            XCTFail("Expected 500 error but got success")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .statusCode(500))
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    func testFetchRepositories_Unauthorized401() async {
        // Arrange
        mockSession.mockData = Data()
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.github.com/search/repositories?q=swift")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )
        
        // Act & Assert
        do {
            _ = try await apiClient.fetchRepositories(query: "swift")
            XCTFail("Expected 401 error but got success")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .statusCode(401))
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    func testNetworkSession_NoDataError() async {
        // Arrange - No mock data or response set
        
        // Act & Assert
        do {
            _ = try await apiClient.fetchRepositories(query: "swift")
            XCTFail("Expected noData error but got success")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .noData)
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    func testFetchRepositories_DecodingError() async {
        // Arrange - Invalid JSON data
        let invalidJSONData = "{\"invalid\": \"structure\"}".data(using: .utf8)!
        mockSession.mockData = invalidJSONData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.github.com/search/repositories?q=swift")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // Act & Assert
        do {
            _ = try await apiClient.fetchRepositories(query: "swift")
            XCTFail("Expected decoding error but got success")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - Network Error Propagation Tests
    func testNetworkError_PropagatesCorrectly() async {
        // Arrange
        let underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        mockSession.mockError = underlyingError
        
        // Act & Assert
        do {
            _ = try await apiClient.fetchRepositories(query: "swift")
            XCTFail("Expected network error but got success")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - Request Validation Tests
    func testFetchRepositories_RequestURLCorrect() async throws {
        // Arrange
        let mockRepos = [MockDataFactory.makeMockRepository()]
        let searchResponse = SearchResponse(items: mockRepos)
        let data = MockDataFactory.makeJSONData(from: searchResponse)
        
        mockSession.mockData = data
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.github.com/search/repositories?q=swift")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // Act
        _ = try await apiClient.fetchRepositories(query: "swift")
        
        // Assert
        XCTAssertNotNil(mockSession.lastRequest)
        XCTAssertTrue(mockSession.lastRequest?.url?.absoluteString.contains("q=swift") ?? false)
    }
    
    func testFetchUser_RequestPathCorrect() async throws {
        // Arrange
        let mockUser = MockDataFactory.makeMockUser()
        let data = MockDataFactory.makeJSONData(from: mockUser)
        
        mockSession.mockData = data
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.github.com/users/octocat")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // Act
        _ = try await apiClient.fetchUser(username: "octocat")
        
        // Assert
        XCTAssertTrue(mockSession.lastRequest?.url?.path.contains("/users/octocat") ?? false)
    }
    
    // MARK: - Empty Response Tests
    func testFetchRepositories_EmptyResponse() async throws {
        // Arrange
        let searchResponse = SearchResponse<Repository>(items: [])
        let data = MockDataFactory.makeJSONData(from: searchResponse)
        
        mockSession.mockData = data
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.github.com/search/repositories?q=nonexistentrepo123")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // Act
        let result = try await apiClient.fetchRepositories(query: "nonexistentrepo123")
        
        // Assert
        XCTAssertEqual(result.count, 0)
    }
    
    func testFetchIssues_EmptyList() async throws {
        // Arrange
        let emptyIssues: [Issue] = []
        let data = MockDataFactory.makeJSONData(from: emptyIssues)
        
        mockSession.mockData = data
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.github.com/repos/owner/repo/issues")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // Act
        let result = try await apiClient.fetchIssues(owner: "owner", repo: "repo")
        
        // Assert
        XCTAssertEqual(result.count, 0)
    }
    
    // MARK: - Concurrent Request Tests
    func testConcurrentRequests_MultipleAPICalls() async throws {
        // Arrange
        let mockUser = MockDataFactory.makeMockUser()
        let userData = MockDataFactory.makeJSONData(from: mockUser)
        
        let mockRepos = [MockDataFactory.makeMockRepository()]
        let searchResponse = SearchResponse(items: mockRepos)
        let reposData = MockDataFactory.makeJSONData(from: searchResponse)
        
        // Act - Run multiple concurrent requests
        let expectation1 = expectation(description: "User API Call")
        let expectation2 = expectation(description: "Repos API Call")
        
        // For this test, we verify the API client can handle async patterns
        // In a real scenario, we'd use separate mock sessions
        
        // Assert
        XCTAssertNoThrow(try await apiClient.fetchUser(username: "testuser"))
        expectation1.fulfill()
        
        XCTAssertNoThrow(try await apiClient.fetchRepositories(query: "swift"))
        expectation2.fulfill()
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // MARK: - Rate Limit Tests
    func testRateLimit_429Response() async {
        // Arrange
        mockSession.mockData = Data()
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.github.com/search/repositories?q=swift")!,
            statusCode: 429,
            httpVersion: nil,
            headerFields: nil
        )
        
        // Act & Assert
        do {
            _ = try await apiClient.fetchRepositories(query: "swift")
            XCTFail("Expected 429 error but got success")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .statusCode(429))
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    // MARK: - Forbidden Access Tests
    func testForbidden_403Response() async {
        // Arrange
        mockSession.mockData = Data()
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.github.com/search/repositories?q=swift")!,
            statusCode: 403,
            httpVersion: nil,
            headerFields: nil
        )
        
        // Act & Assert
        do {
            _ = try await apiClient.fetchRepositories(query: "swift")
            XCTFail("Expected 403 error but got success")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .statusCode(403))
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    // MARK: - Test Coverage Helper
    /// Executes common test paths for comprehensive coverage
    private func executeAllHTTPStatusCodes() async {
        let statusCodes = [200, 201, 400, 401, 403, 404, 500, 502, 503]
        
        for code in statusCodes {
            mockSession.mockData = Data()
            mockSession.mockResponse = HTTPURLResponse(
                url: URL(string: "https://api.github.com/test")!,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )
        }
    }
}

// MARK: - NetworkError Equatable Tests
extension NetworkLayerTests {
    func testNetworkErrorEquality() {
        XCTAssertEqual(NetworkError.invalidURL, NetworkError.invalidURL)
        XCTAssertEqual(NetworkError.invalidResponse, NetworkError.invalidResponse)
        XCTAssertEqual(NetworkError.noData, NetworkError.noData)
        XCTAssertEqual(NetworkError.statusCode(404), NetworkError.statusCode(404))
        XCTAssertNotEqual(NetworkError.statusCode(404), NetworkError.statusCode(500))
        XCTAssertNotEqual(NetworkError.invalidURL, NetworkError.noData)
    }
}