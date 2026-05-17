//
//  RepositoryRepository.swift
//  GitHubiOS
//
//  Created by iOS Architect on 5/17/26.
//

import Foundation
import Combine

protocol RepositoryRepositoryProtocol {
    func getRepositories(perPage: Int, page: Int) -> AnyPublisher<[Repository], NetworkError>
    func searchRepositories(query: String, perPage: Int, page: Int) -> AnyPublisher<SearchRepositoriesResponse, NetworkError>
    func getRepository(owner: String, name: String) -> AnyPublisher<Repository, NetworkError>
}
