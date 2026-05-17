//
//  RepositoryLocalDataSource.swift
//  GitHubiOS
//
//  Created by iOS Architect on 5/17/26.
//

import Foundation
import Combine

protocol RepositoryLocalDataSourceProtocol {
    func saveRepositories(_ repositories: [Repository]) throws
    func getCachedRepositories() -> [Repository]?
    func clearCache() throws
}

final class RepositoryLocalDataSource: RepositoryLocalDataSourceProtocol {
    private let userDefaults: UserDefaults
    private let cacheKey = "cached_repositories"
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init(
        userDefaults: UserDefaults = .standard,
        decoder: JSONDecoder = .defaultDecoder,
        encoder: JSONEncoder = .defaultEncoder
    ) {
        self.userDefaults = userDefaults
        self.decoder = decoder
        self.encoder = encoder
    }
    
    func saveRepositories(_ repositories: [Repository]) throws {
        let data = try encoder.encode(repositories)
        userDefaults.set(data, forKey: cacheKey)
    }
    
    func getCachedRepositories() -> [Repository]? {
        guard let data = userDefaults.data(forKey: cacheKey) else {
            return nil
        }
        
        do {
            return try decoder.decode([Repository].self, from: data)
        } catch {
            print("❌ Failed to decode cached repositories: \(error)")
            return nil
        }
    }
    
    func clearCache() throws {
        userDefaults.removeObject(forKey: cacheKey)
    }
}

// MARK: - JSONEncoder Default
extension JSONEncoder {
    static var defaultEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}
