//
//  RepositoryRemoteDataSource.swift
//  GitHubiOS
//
//  Created by iOS Architect on 5/17/26.
//

import Foundation
import Combine

protocol RepositoryRemoteDataSourceProtocol {
    func getRepositories(perPage: Int, page: Int) -> AnyPublisher<[Repository], NetworkError>
    func searchRepositories(query: String, perPage: Int, page: Int) -> AnyPublisher<SearchRepositoriesResponse, NetworkError>
    func getRepository(owner: String, name: String) -> AnyPublisher<Repository, NetworkError>
}

final class RepositoryRemoteDataSource: RepositoryRemoteDataSourceProtocol {
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    func getRepositories(perPage: Int, page: Int) -> AnyPublisher<[Repository], NetworkError> {
        return networkClient.request(
            .getRepositories(perPage: perPage, page: page),
            responseType: [Repository].self
        )
    }
    
    func searchRepositories(query: String, perPage: Int, page: Int) -> AnyPublisher<SearchRepositoriesResponse, NetworkError> {
        return networkClient.request(
            .searchRepositories(query: query, perPage: perPage, page: page),
            responseType: SearchRepositoriesResponse.self
        )
    }
    
    func getRepository(owner: String, name: String) -> AnyPublisher<Repository, NetworkError> {
        return networkClient.request(
            .getRepository(owner: owner, name: name),
            responseType: Repository.self
        )
    }
}
