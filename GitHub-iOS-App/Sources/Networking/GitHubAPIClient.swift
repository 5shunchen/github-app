//
//  GitHubAPIClient.swift
//  GitHubApp
//
//  Created by C on 2026/05/17.
//

import Foundation

public enum APIError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case unauthorized
    case decodingError(Error)
    case serverError(String)
}

public final class GitHubAPIClient {
    public static let shared = GitHubAPIClient()
    
    private let baseURL = "https://api.github.com"
    private let urlSession: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.urlSession = URLSession(configuration: configuration)
    }
    
    public func request<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        if requiresAuth {
            if let token = GitHubAuthManager.shared.currentToken {
                if token.needsRefresh {
                    try await refreshTokenIfNeeded()
                }
                request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
            } else {
                throw APIError.unauthorized
            }
        }
        
        if let parameters = parameters {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                return try JSONDecoder().decode(T.self, from: data)
            case 401:
                try await refreshTokenIfNeeded()
                return try await retryRequest(endpoint, method: method, parameters: parameters)
            case 400...499:
                throw APIError.serverError("Client error: \(httpResponse.statusCode)")
            case 500...599:
                throw APIError.serverError("Server error: \(httpResponse.statusCode)")
            default:
                throw APIError.invalidResponse
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    private func refreshTokenIfNeeded() async throws {
        guard let token = GitHubAuthManager.shared.currentToken,
              token.needsRefresh else { return }
        
        try await withCheckedThrowingContinuation { continuation in
            TokenRefreshManager.shared.refreshToken { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func retryRequest<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]?
    ) async throws -> T {
        guard let token = GitHubAuthManager.shared.currentToken else {
            throw APIError.unauthorized
        }
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        
        if let parameters = parameters {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.unauthorized
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    public func requestData(
        _ url: URL,
        requiresAuth: Bool = false
    ) async throws -> Data {
        var request = URLRequest(url: url)
        
        if requiresAuth, let token = GitHubAuthManager.shared.currentToken {
            request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, _) = try await urlSession.data(for: request)
        return data
    }
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}
