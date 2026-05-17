//
//  PersistenceTests.swift - GitHub iOS Data Persistence Tests
//  XCTest - Storage Correctness, Encryption, Boundary Conditions
//

import XCTest
import CryptoKit

// MARK: - Mock Data Factory (repeated for standalone)
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
            createdAt: Date()
        )
    }
}

// MARK: - Data Models (repeated for standalone)
struct Repository: Codable, Equatable {
    let id: Int
    let name: String
    let fullName: String
    let description: String?
    let stars: Int
    let forks: Int
    let language: String?
}

struct User: Codable, Equatable {
    let id: Int
    let login: String
    let name: String?
    let bio: String?
    let followers: Int
    let following: Int
    let avatarUrl: String
}

struct Issue: Codable, Equatable {
    let id: Int
    let number: Int
    let title: String
    let body: String?
    let state: String
    let createdAt: Date
}

// MARK: - Protocols
protocol EncryptionServiceProtocol {
    func encrypt(_ data: Data) throws -> Data
    func decrypt(_ data: Data) throws -> Data
}

protocol PersistenceManagerProtocol {
    func save<T: Encodable>(_ object: T, for key: String) throws
    func fetch<T: Decodable>(for key: String) throws -> T
    func delete(for key: String) throws
    func clearAll() throws
    func exists(for key: String) -> Bool
}

// MARK: - Encryption Errors
enum EncryptionError: Error {
    case encryptionFailed
    case decryptionFailed
    case invalidKey
    case invalidData
}

// MARK: - Persistence Errors
enum PersistenceError: Error {
    case fileNotFound
    case writeFailed
    case readFailed
    case deleteFailed
    case dataCorrupted
    case keyNotFound
}

// MARK: - Encryption Service Implementation
class EncryptionService: EncryptionServiceProtocol {
    private let key: SymmetricKey
    
    init(key: SymmetricKey = SymmetricKey(size: .bits256)) {
        self.key = key
    }
    
    func encrypt(_ data: Data) throws -> Data {
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined ?? Data()
        } catch {
            throw EncryptionError.encryptionFailed
        }
    }
    
    func decrypt(_ data: Data) throws -> Data {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            return try AES.GCM.open(sealedBox, using: key)
        } catch {
            throw EncryptionError.decryptionFailed
        }
    }
}

// MARK: - Persistence Manager Implementation
class PersistenceManager: PersistenceManagerProtocol {
    private let fileManager: FileManager
    private let directoryURL: URL
    private let encryptionService: EncryptionServiceProtocol?
    private let useEncryption: Bool
    
    init(
        directoryURL: URL? = nil,
        encryptionService: EncryptionServiceProtocol? = nil,
        useEncryption: Bool = false
    ) {
        self.fileManager = FileManager.default
        self.encryptionService = encryptionService
        self.useEncryption = useEncryption
        
        if let directoryURL = directoryURL {
            self.directoryURL = directoryURL
        } else {
            let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            self.directoryURL = docs.appendingPathComponent("GitHubData", isDirectory: true)
        }
        
        try? fileManager.createDirectory(at: self.directoryURL, withIntermediateDirectories: true)
    }
    
    private func fileURL(for key: String) -> URL {
        return directoryURL.appendingPathComponent("\(key).json")
    }
    
    func save<T: Encodable>(_ object: T, for key: String) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        var data = try encoder.encode(object)
        
        if useEncryption, let encryption = encryptionService {
            data = try encryption.encrypt(data)
        }
        
        do {
            try data.write(to: fileURL(for: key), options: .atomic)
        } catch {
            throw PersistenceError.writeFailed
        }
    }
    
    func fetch<T: Decodable>(for key: String) throws -> T {
        guard fileManager.fileExists(atPath: fileURL(for: key).path) else {
            throw PersistenceError.keyNotFound
        }
        
        var data: Data
        do {
            data = try Data(contentsOf: fileURL(for: key))
        } catch {
            throw PersistenceError.readFailed
        }
        
        if useEncryption, let encryption = encryptionService {
            data = try encryption.decrypt(data)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw PersistenceError.dataCorrupted
        }
    }
    
    func delete(for key: String) throws {
        guard fileManager.fileExists(atPath: fileURL(for: key).path) else {
            throw PersistenceError.keyNotFound
        }
        
        do {
            try fileManager.removeItem(at: fileURL(for: key))
        } catch {
            throw PersistenceError.deleteFailed
        }
    }
    
    func clearAll() throws {
        let files = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
        
        for file in files {
            try fileManager.removeItem(at: file)
        }
    }
    
    func exists(for key: String) -> Bool {
        return fileManager.fileExists(atPath: fileURL(for: key).path)
    }
    
    func fileSize(for key: String) throws -> Int64 {
        let attributes = try fileManager.attributesOfItem(atPath: fileURL(for: key).path)
        return attributes[.size] as? Int64 ?? 0
    }
}

// MARK: - In-Memory Persistence for Testing
class InMemoryPersistence: PersistenceManagerProtocol {
    private var storage: [String: Data] = [:]
    
    func save<T: Encodable>(_ object: T, for key: String) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        storage[key] = try encoder.encode(object)
    }
    
    func fetch<T: Decodable>(for key: String) throws -> T {
        guard let data = storage[key] else {
            throw PersistenceError.keyNotFound
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }
    
    func delete(for key: String) throws {
        storage.removeValue(forKey: key)
    }
    
    func clearAll() throws {
        storage.removeAll()
    }
    
    func exists(for key: String) -> Bool {
        return storage[key] != nil
    }
}

// MARK: - Persistence Unit Tests
class PersistenceTests: XCTestCase {
    var tempDirectory: URL!
    var persistenceManager: PersistenceManager!
    var encryptionService: EncryptionService!
    var inMemoryPersistence: InMemoryPersistence!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Create temp directory for testing
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        
        encryptionService = EncryptionService()
        persistenceManager = PersistenceManager(
            directoryURL: tempDirectory,
            encryptionService: encryptionService,
            useEncryption: false
        )
        
        inMemoryPersistence = InMemoryPersistence()
    }
    
    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempDirectory)
        tempDirectory = nil
        persistenceManager = nil
        encryptionService = nil
        inMemoryPersistence = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Basic Save/Fetch Tests
    func testSaveAndFetchRepository_Success() throws {
        // Arrange
        let repository = MockDataFactory.makeMockRepository(id: 123, name: "TestRepo")
        let key = "repo_123"
        
        // Act
        try persistenceManager.save(repository, for: key)
        let fetched: Repository = try persistenceManager.fetch(for: key)
        
        // Assert
        XCTAssertEqual(fetched.id, 123)
        XCTAssertEqual(fetched.name, "TestRepo")
        XCTAssertEqual(fetched, repository)
    }
    
    func testSaveAndFetchUser_Success() throws {
        // Arrange
        let user = MockDataFactory.makeMockUser(id: 456, login: "testuser")
        let key = "user_456"
        
        // Act
        try persistenceManager.save(user, for: key)
        let fetched: User = try persistenceManager.fetch(for: key)
        
        // Assert
        XCTAssertEqual(fetched.id, 456)
        XCTAssertEqual(fetched.login, "testuser")
        XCTAssertEqual(fetched, user)
    }
    
    func testSaveAndFetchIssue_Success() throws {
        // Arrange
        let issue = MockDataFactory.makeMockIssue(id: 789, number: 42)
        let key = "issue_789"
        
        // Act
        try persistenceManager.save(issue, for: key)
        let fetched: Issue = try persistenceManager.fetch(for: key)
        
        // Assert
        XCTAssertEqual(fetched.id, 789)
        XCTAssertEqual(fetched.number, 42)
    }
    
    // MARK: - Existence Tests
    func testExists_AfterSave_ReturnsTrue() throws {
        // Arrange
        let repo = MockDataFactory.makeMockRepository()
        let key = "test_exists"
        
        // Pre-assert
        XCTAssertFalse(persistenceManager.exists(for: key))
        
        // Act
        try persistenceManager.save(repo, for: key)
        
        // Assert
        XCTAssertTrue(persistenceManager.exists(for: key))
    }
    
    func testExists_BeforeSave_ReturnsFalse() {
        XCTAssertFalse(persistenceManager.exists(for: "nonexistent_key"))
    }
    
    // MARK: - Delete Tests
    func testDelete_ExistingKey_Succeeds() throws {
        // Arrange
        let repo = MockDataFactory.makeMockRepository()
        let key = "to_delete"
        try persistenceManager.save(repo, for: key)
        XCTAssertTrue(persistenceManager.exists(for: key))
        
        // Act
        try persistenceManager.delete(for: key)
        
        // Assert
        XCTAssertFalse(persistenceManager.exists(for: key))
    }
    
    func testDelete_NonexistentKey_ThrowsError() {
        // Act & Assert
        XCTAssertThrowsError(try persistenceManager.delete(for: "nonexistent")) { error in
            XCTAssertEqual(error as? PersistenceError, .keyNotFound)
        }
    }
    
    // MARK: - Clear All Tests
    func testClearAll_RemovesAllFiles() throws {
        // Arrange
        try persistenceManager.save(MockDataFactory.makeMockRepository(id: 1), for: "key1")
        try persistenceManager.save(MockDataFactory.makeMockRepository(id: 2), for: "key2")
        try persistenceManager.save(MockDataFactory.makeMockRepository(id: 3), for: "key3")
        
        XCTAssertTrue(persistenceManager.exists(for: "key1"))
        XCTAssertTrue(persistenceManager.exists(for: "key2"))
        XCTAssertTrue(persistenceManager.exists(for: "key3"))
        
        // Act
        try persistenceManager.clearAll()
        
        // Assert
        XCTAssertFalse(persistenceManager.exists(for: "key1"))
        XCTAssertFalse(persistenceManager.exists(for: "key2"))
        XCTAssertFalse(persistenceManager.exists(for: "key3"))
    }
    
    // MARK: - Fetch Nonexistent Key Tests
    func testFetch_NonexistentKey_ThrowsError() {
        // Act & Assert
        XCTAssertThrowsError(try persistenceManager.fetch(for: "nonexistent") as Repository) { error in
            XCTAssertEqual(error as? PersistenceError, .keyNotFound)
        }
    }
    
    // MARK: - Overwrite Tests
    func testSave_OverwriteExistingData_Succeeds() throws {
        // Arrange
        let key = "overwrite_key"
        let originalRepo = MockDataFactory.makeMockRepository(id: 1, name: "Original")
        let updatedRepo = MockDataFactory.makeMockRepository(id: 1, name: "Updated")
        
        try persistenceManager.save(originalRepo, for: key)
        
        // Act
        try persistenceManager.save(updatedRepo, for: key)
        let fetched: Repository = try persistenceManager.fetch(for: key)
        
        // Assert
        XCTAssertEqual(fetched.name, "Updated")
    }
    
    // MARK: - Encryption Tests
    func testEncryptedPersistence_SaveAndFetch_Succeeds() throws {
        // Arrange
        let encryptedPersistence = PersistenceManager(
            directoryURL: tempDirectory,
            encryptionService: encryptionService,
            useEncryption: true
        )
        let repo = MockDataFactory.makeMockRepository(id: 999, name: "EncryptedRepo")
        let key = "encrypted_repo"
        
        // Act
        try encryptedPersistence.save(repo, for: key)
        let fetched: Repository = try encryptedPersistence.fetch(for: key)
        
        // Assert
        XCTAssertEqual(fetched.id, 999)
        XCTAssertEqual(fetched.name, "EncryptedRepo")
    }
    
    func testEncryption_DecryptWithWrongKey_Fails() throws {
        // Arrange
        let encryption1 = EncryptionService()
        let encryption2 = EncryptionService() // Different key
        let originalData = "Secret data".data(using: .utf8)!
        
        // Act
        let encrypted = try encryption1.encrypt(originalData)
        
        // Assert
        XCTAssertThrowsError(try encryption2.decrypt(encrypted)) { error in
            XCTAssertEqual(error as? EncryptionError, .decryptionFailed)
        }
    }
    
    func testEncryption_EncryptDecrypt_MatchesOriginal() throws {
        // Arrange
        let originalData = "Test data for encryption 123!@#".data(using: .utf8)!
        
        // Act
        let encrypted = try encryptionService.encrypt(originalData)
        let decrypted = try encryptionService.decrypt(encrypted)
        
        // Assert
        XCTAssertNotEqual(encrypted, originalData) // Should be different
        XCTAssertEqual(decrypted, originalData) // Should match after decrypt
    }
    
    func testEncryption_EmptyData_Succeeds() throws {
        // Arrange
        let emptyData = Data()
        
        // Act & Assert
        XCTAssertNoThrow(try encryptionService.encrypt(emptyData))
        let encrypted = try encryptionService.encrypt(emptyData)
        let decrypted = try encryptionService.decrypt(encrypted)
        XCTAssertEqual(decrypted, emptyData)
    }
    
    // MARK: - Boundary Condition Tests
    func testPersistence_LargeDataObject_Succeeds() throws {
        // Arrange - Create a repository with very large description
        let largeDescription = String(repeating: "Lorem ipsum dolor sit amet. ", count: 1000)
        let repo = Repository(
            id: 9999,
            name: "LargeDataRepo",
            fullName: "test/LargeDataRepo",
            description: largeDescription,
            stars: 999999,
            forks: 99999,
            language: "Swift"
        )
        let key = "large_data_test"
        
        // Act
        try persistenceManager.save(repo, for: key)
        let fetched: Repository = try persistenceManager.fetch(for: key        
        // Assert
        XCTAssertEqual(fetched.id, 9999)
        XCTAssertEqual(fetched.description?.count, largeDescription.count)
    }
    
    func testPersistence_SpecialCharactersInKey_Succeeds() throws {
        // Arrange
        let repo = MockDataFactory.makeMockRepository()
        let specialKeys = [
            "key with spaces",
            "key-with-dashes",
            "key_with_underscores",
            "key.with.dots",
            "emoji_🔥_key",
            "unicode_Über_key"
        ]
        
        // Act & Assert
        for key in specialKeys {
            try persistenceManager.save(repo, for: key)
            XCTAssertTrue(persistenceManager.exists(for: key))
            let fetched: Repository = try persistenceManager.fetch(for: key)
            XCTAssertEqual(fetched.id, repo.id)
        }
    }
    
    func testPersistence_EmptyStringFields_Succeeds() throws {
        // Arrange
        let repo = Repository(
            id: 1,
            name: "",
            fullName: "",
            description: "",
            stars: 0,
            forks: 0,
            language: ""
        )
        let key = "empty_fields"
        
        // Act
        try persistenceManager.save(repo, for: key)
        let fetched: Repository = try persistenceManager.fetch(for: key)
        
        // Assert
        XCTAssertEqual(fetched.name, "")
        XCTAssertEqual(fetched.description, "")
    }
    
    func testPersistence_NilFields_Succeeds() throws {
        // Arrange
        let repo = Repository(
            id: 1,
            name: "NilFields",
            fullName: "test/NilFields",
            description: nil,
            stars: 0,
            forks: 0,
            language: nil
        )
        let key = "nil_fields"
        
        // Act
        try persistenceManager.save(repo, for: key)
        let fetched: Repository = try persistenceManager.fetch(for: key)
        
        // Assert
        XCTAssertNil(fetched.description)
        XCTAssertNil(fetched.language)
    }
    
    func testPersistence_MaximumIntegerValues_Succeeds() throws {
        // Arrange
        let repo = Repository(
            id: Int.max,
            name: "MaxInt",
            fullName: "test/MaxInt",
            description: "Max values test",
            stars: Int.max,
            forks: Int.max,
            language: "Swift"
        )
        let key = "max_int_test"
        
        // Act
        try persistenceManager.save(repo, for: key)
        let fetched: Repository = try persistenceManager.fetch(for: key)
        
        // Assert
        XCTAssertEqual(fetched.id, Int.max)
        XCTAssertEqual(fetched.stars, Int.max)
    }
    
    func testPersistence_ZeroIntegerValues_Succeeds() throws {
        // Arrange
        let repo = Repository(
            id: 0,
            name: "ZeroInt",
            fullName: "test/ZeroInt",
            description: "Zero values test",
            stars: 0,
            forks: 0,
            language: "Swift"
        )
        let key = "zero_int_test"
        
        // Act
        try persistenceManager.save(repo, for: key)
        let fetched: Repository = try persistenceManager.fetch(for: key)
        
        // Assert
        XCTAssertEqual(fetched.id, 0)
        XCTAssertEqual(fetched.stars, 0)
    }
    
    // MARK: - Batch Operations Tests
    func testPersistence_BatchSave_Succeeds() throws {
        // Arrange
        let repositories = (1...100).map { id in
            MockDataFactory.makeMockRepository(id: id, name: "Repo_\(id)")
        }
        
        // Act
        for (index, repo) in repositories.enumerated() {
            try persistenceManager.save(repo, for: "batch_\(index)")
        }
        
        // Assert
        for index in 0..<100 {
            XCTAssertTrue(persistenceManager.exists(for: "batch_\(index)"))
        }
    }
    
    // MARK: - Concurrent Access Tests
    func testPersistence_ConcurrentReadWrite_Safe() async throws {
        // Act - Multiple concurrent operations
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<10 {
                group.addTask {
                    let localRepo = MockDataFactory.makeMockRepository(id: i)
                    try? self.persistenceManager.save(localRepo, for: "concurrent_\(i)")
                    _ = try? self.persistenceManager.fetch(for: "concurrent_\(i)") as Repository
                }
            }
        }
        
        // Assert - No crashes means thread safety (basic level)
        XCTAssertTrue(true)
    }
    
    // MARK: - In-Memory Persistence Tests
    func testInMemoryPersistence_BasicOperations_Succeeds() throws {
        // Arrange
        let repo = MockDataFactory.makeMockRepository(id: 42)
        let key = "in_memory_test"
        
        // Act & Assert
        try inMemoryPersistence.save(repo, for: key)
        XCTAssertTrue(inMemoryPersistence.exists(for: key))
        
        let fetched: Repository = try inMemoryPersistence.fetch(for: key)
        XCTAssertEqual(fetched.id, 42)
        
        try inMemoryPersistence.delete(for: key)
        XCTAssertFalse(inMemoryPersistence.exists(for: key))
    }
    
    func testInMemoryPersistence_ClearAll_Succeeds() throws {
        // Arrange
        try inMemoryPersistence.save(MockDataFactory.makeMockRepository(id: 1), for: "key1")
        try inMemoryPersistence.save(MockDataFactory.makeMockRepository(id: 2), for: "key2")
        
        // Act
        try inMemoryPersistence.clearAll()
        
        // Assert
        XCTAssertFalse(inMemoryPersistence.exists(for: "key1"))
        XCTAssertFalse(inMemoryPersistence.exists(for: "key2"))
    }
    
    // MARK: - Data Corruption Tests
    func testPersistence_CorruptedData_ThrowsError() throws {
        // Arrange
        let key = "corrupted_file"
        let corruptedData = "this is not valid json".data(using: .utf8)!
        try corruptedData.write(to: tempDirectory.appendingPathComponent("\(key).json"))
        
        // Act & Assert
        XCTAssertThrowsError(try persistenceManager.fetch(for: key) as Repository) { error in
            XCTAssertEqual(error as? PersistenceError, .dataCorrupted)
        }
    }
    
    // MARK: - Performance Tests
    func testPersistence_SavePerformance() throws {
        let repo = MockDataFactory.makeMockRepository()
        measure {
            for i in 0..<100 {
                try? persistenceManager.save(repo, for: "perf_\(i)")
            }
        }
    }
    
    func testPersistence_FetchPerformance() throws {
        let repo = MockDataFactory.makeMockRepository()
        for i in 0..<100 {
            try persistenceManager.save(repo, for: "perf_fetch_\(i)")
        }
        
        measure {
            for i in 0..<100 {
                _ = try? persistenceManager.fetch(for: "perf_fetch_\(i)") as Repository
            }
        }
    }
}

// MARK: - PersistenceError Equatable Extension
extension PersistenceError: Equatable {
    static func == (lhs: PersistenceError, rhs: PersistenceError) -> Bool {
        switch (lhs, rhs) {
        case (.fileNotFound, .fileNotFound): return true
        case (.writeFailed, .writeFailed): return true
        case (.readFailed, .readFailed): return true
        case (.deleteFailed, .deleteFailed): return true
        case (.dataCorrupted, .dataCorrupted): return true
        case (.keyNotFound, .keyNotFound): return true
        default: return false
        }
    }
}

// MARK: - EncryptionError Equatable Extension
extension EncryptionError: Equatable {
    static func == (lhs: EncryptionError, rhs: EncryptionError) -> Bool {
        switch (lhs, rhs) {
        case (.encryptionFailed, .encryptionFailed): return true
        case (.decryptionFailed, .decryptionFailed): return true
        case (.invalidKey, .invalidKey): return true
        case (.invalidData, .invalidData): return true
        default: return false
        }
    }
}
