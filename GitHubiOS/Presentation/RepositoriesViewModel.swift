//
//  RepositoriesViewModel.swift
//  GitHubiOS
//
//  Created by iOS Architect on 5/17/26.
//

import Foundation
import Combine

final class RepositoriesViewModel: ObservableObject {
    @Published var repositories: [Repository] = []
    @Published var isLoading: Bool = false
    @Published var error: NetworkError?
    
    private let repository: RepositoryRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private var currentPage = 1
    private let perPage = 20
    
    init(repository: RepositoryRepositoryProtocol = RepositoryRepositoryImpl()) {
        self.repository = repository
    }
    
    func fetchRepositories() {
        isLoading = true
        error = nil
        
        repository.getRepositories(perPage: perPage, page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    self.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self.error = error
                        print("❌ Failed to fetch repositories: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] repositories in
                    guard let self = self else { return }
                    self.repositories = repositories
                    print("✅ Fetched \(repositories.count) repositories")
                }
            )
            .store(in: &cancellables)
    }
    
    func loadNextPage() {
        currentPage += 1
        fetchRepositories()
    }
    
    func refresh() {
        currentPage = 1
        fetchRepositories()
    }
}
