//
//  RepositoryRepositoryImpl.swift
//  GitHubiOS
//
//  Created by iOS Architect on 5/17/26.
//

import Foundation
import Combine

final class RepositoryRepositoryImpl: RepositoryRepositoryProtocol {
    private let remoteDataSource: RepositoryRemoteDataSourceProtocol
    private let localDataSource: RepositoryLocalDataSourceProtocol
    
    init(
        remoteDataSource: RepositoryRemoteDataSourceProtocol = RepositoryRemoteDataSource(),
        localDataSource: RepositoryLocalDataSourceProtocol = RepositoryLocalDataSource()
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    func getRepositories(perPage: Int, page: Int) -> AnyPublisher<[Repository], NetworkError> {
        // First return cached data, then fetch from network and update cache
        let cached = Just(localDataSource.getCachedRepositories() ?? [])
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let remote = remoteDataSource.getRepositories(perPage: perPage, page: page)
            .handleEvents(receiveOutput: { [weak self] repositories in
                try? self?.localDataSource.saveRepositories(repositories)
            })
            .eraseToAnyPublisher()
        
        return Publishers.Merge(cached, remote)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func searchRepositories(query: String, perPage: Int, page: Int) -> AnyPublisher<SearchRepositoriesResponse, NetworkError> {
        // Search results are not cached by default
        return remoteDataSource.searchRepositories(query: query, perPage: perPage, page: page)
    }
    
    func getRepository(owner: String, name: String) -> AnyPublisher<Repository, NetworkError> {
        return remoteDataSource.getRepository(owner: owner, name: name)
    }
}
