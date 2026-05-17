//
//  Project.swift - GitHub iOS Test Project Structure
//  XCTest Framework Setup
//

import Foundation
import XCTest

// MARK: - Mock Network Layer Protocol
protocol NetworkSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

// MARK: - APIClient Protocol
protocol APIClientProtocol {
    func fetchRepositories(query: String) async throws -> [Repository]
    func fetchUser(username: String) async throws -> User
    func fetchIssues(owner: String, repo: String) async throws -> [Issue]
}

// MARK: - Data Models
struct Repository: Codable, Equatable {
    let id: Int
    let name: String
    let fullName: String
    let description: String?
    let stars: Int
    let forks: Int
    let language: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description
        case fullName = "full_name"
        case stars = "stargazers_count"
        case forks = "forks_count"
        case language
    }
}

struct User: Codable, Equatable {
    let id: Int
    let login: String
    let name: String?
    let bio: String?
    let followers: Int
    let following: Int
    let avatarUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id, login, name, bio, followers, following
        case avatarUrl = "avatar_url"
    }
}

struct Issue: Codable, Equatable {
    let id: Int
    let number: Int
    let title: String
    let body: String?
    let state: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, number, title, body, state
        case createdAt = "created_at"
    }
}

// MARK: - Persistence Protocol
protocol PersistenceManagerProtocol {
    func save<T: Encodable>(_ object: T, for key: String) throws
    func fetch<T: Decodable>(for key: String) throws -> T
    func delete(for key: String) throws
    func clearAll() throws
    func exists(for key: String) -> Bool
}

// MARK: - Encryption Protocol
protocol EncryptionServiceProtocol {
    func encrypt(_ data: Data) throws -> Data
    func decrypt(_ data: Data) throws -> Data
}
