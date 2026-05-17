//
//  TokenRefreshManager.swift
//  GitHubApp
//
//  Created by C on 2026/05/17.
//

import Foundation

public protocol TokenRefreshManagerDelegate: AnyObject {
    func tokenRefreshDidSucceed(with newToken: GitHubToken)
    func tokenRefreshDidFail(with error: GitHubAuthError)
}

public final class TokenRefreshManager {
    public static let shared = TokenRefreshManager()
    
    public weak var delegate: TokenRefreshManagerDelegate?
    public private(set) var isRefreshing = false
    
    private var refreshTimer: Timer?
    private let minimumRefreshInterval: TimeInterval = 300
    
    private init() {
        setupAutoRefresh()
    }
    
    public func setupAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(
            withTimeInterval: 60,
            repeats: true
        ) { [weak self] _ in
            self?.checkAndRefreshTokenIfNeeded()
        }
    }
    
    public func checkAndRefreshTokenIfNeeded() {
        guard !isRefreshing else { return }
        
        guard let token = GitHubAuthManager.shared.currentToken,
              token.needsRefresh else { return }
        
        refreshToken()
    }
    
    public func refreshToken(completion: ((Result<GitHubToken, GitHubAuthError>) -> Void)? = nil) {
        guard !isRefreshing else { return }
        guard let token = GitHubAuthManager.shared.currentToken,
              let refreshToken = token.refreshToken else {
            completion?(.failure(.tokenExchangeFailed))
            return
        }
        
        guard let config = GitHubAuthManager.shared.config else {
            completion?(.failure(.tokenExchangeFailed))
            return
        }
        
        isRefreshing = true
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "github.com"
        components.path = "/login/oauth/access_token"
        components.queryItems = [
            URLQueryItem(name: "client_id", value: config.clientId),
            URLQueryItem(name: "client_secret", value: config.clientSecret),
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.handleRefreshResponse(
                    data: data,
                    response: response,
                    error: error,
                    completion: completion
                )
            }
        }.resume()
    }
    
    private func handleRefreshResponse(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: ((Result<GitHubToken, GitHubAuthError>) -> Void)?
    ) {
        isRefreshing = false
        
        if let error = error {
            delegate?.tokenRefreshDidFail(with: .networkError(error))
            completion?(.failure(.networkError(error)))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode),
              let data = data else {
            delegate?.tokenRefreshDidFail(with: .invalidResponse)
            completion?(.failure(.invalidResponse))
            return
        }
        
        do {
            let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
            let newToken = GitHubToken(
                accessToken: tokenResponse.access_token,
                tokenType: tokenResponse.token_type,
                scope: tokenResponse.scope,
                refreshToken: tokenResponse.refresh_token,
                expiresIn: tokenResponse.expires_in
            )
            
            GitHubAuthManager.shared.currentToken = newToken
            try KeychainManager.shared.updateToken(newToken)
            
            delegate?.tokenRefreshDidSucceed(with: newToken)
            completion?(.success(newToken))
        } catch {
            delegate?.tokenRefreshDidFail(with: .tokenExchangeFailed)
            completion?(.failure(.tokenExchangeFailed))
        }
    }
    
    public func invalidate() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
}
