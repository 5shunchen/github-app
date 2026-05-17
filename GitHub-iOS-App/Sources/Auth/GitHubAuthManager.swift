//
//  GitHubAuthManager.swift
//  GitHubApp
//
//  Created by C on 2026/05/17.
//

import Foundation
import SafariServices
import UIKit

public protocol GitHubAuthManagerDelegate: AnyObject {
    func authDidSucceed(with token: GitHubToken)
    func authDidFail(with error: GitHubAuthError)
}

public enum GitHubAuthError: Error {
    case invalidCode
    case invalidResponse
    case networkError(Error)
    case tokenExchangeFailed
    case userCancelled
}

public struct GitHubToken: Codable, Equatable {
    public let accessToken: String
    public let tokenType: String
    public let scope: String
    public let refreshToken: String?
    public let expiresIn: TimeInterval?
    public let createdAt: Date
    
    public init(
        accessToken: String,
        tokenType: String,
        scope: String,
        refreshToken: String? = nil,
        expiresIn: TimeInterval? = nil
    ) {
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.scope = scope
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
        self.createdAt = Date()
    }
    
    public var isExpired: Bool {
        guard let expiresIn = expiresIn else { return false }
        return Date().timeIntervalSince(createdAt) > expiresIn
    }
    
    public var needsRefresh: Bool {
        guard let expiresIn = expiresIn, refreshToken != nil else { return false }
        let refreshThreshold = expiresIn * 0.8
        return Date().timeIntervalSince(createdAt) > refreshThreshold
    }
}

public final class GitHubAuthManager: NSObject {
    public static let shared = GitHubAuthManager()
    
    public weak var delegate: GitHubAuthManagerDelegate?
    public private(set) var currentToken: GitHubToken?
    public private(set) var isAuthenticated = false
    
    private var config: GitHubAuthConfig?
    private var authenticationCompletion: ((Result<GitHubToken, GitHubAuthError>) -> Void)?
    private var safariViewController: SFSafariViewController?
    
    private override init() {
        super.init()
        loadTokenFromKeychain()
    }
    
    public func configure(with config: GitHubAuthConfig) {
        self.config = config
    }
    
    public func authenticate(
        from viewController: UIViewController,
        completion: @escaping (Result<GitHubToken, GitHubAuthError>) -> Void
    ) {
        guard let config = config else {
            completion(.failure(.tokenExchangeFailed))
            return
        }
        
        authenticationCompletion = completion
        
        let safariVC = SFSafariViewController(url: config.authorizeURL)
        safariVC.delegate = self
        self.safariViewController = safariVC
        viewController.present(safariVC, animated: true)
    }
    
    public func handleCallback(url: URL) {
        guard let code = extractCode(from: url) else {
            delegate?.authDidFail(with: .invalidCode)
            authenticationCompletion?(.failure(.invalidCode))
            return
        }
        
        exchangeCodeForToken(code: code)
    }
    
    private func extractCode(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let codeItem = components.queryItems?.first(where: { $0.name == "code" }) else {
            return nil
        }
        return codeItem.value
    }
    
    private func exchangeCodeForToken(code: String) {
        guard let config = config else { return }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "github.com"
        components.path = "/login/oauth/access_token"
        components.queryItems = [
            URLQueryItem(name: "client_id", value: config.clientId),
            URLQueryItem(name: "client_secret", value: config.clientSecret),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: config.redirectUri)
        ]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.handleTokenResponse(data: data, response: response, error: error)
            }
        }.resume()
    }
    
    private func handleTokenResponse(data: Data?, response: URLResponse?, error: Error?) {
        if let error = error {
            delegate?.authDidFail(with: .networkError(error))
            authenticationCompletion?(.failure(.networkError(error)))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode),
              let data = data else {
            delegate?.authDidFail(with: .invalidResponse)
            authenticationCompletion?(.failure(.invalidResponse))
            return
        }
        
        do {
            let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
            let token = GitHubToken(
                accessToken: tokenResponse.access_token,
                tokenType: tokenResponse.token_type,
                scope: tokenResponse.scope,
                refreshToken: tokenResponse.refresh_token,
                expiresIn: tokenResponse.expires_in
            )
            
            currentToken = token
            isAuthenticated = true
            
            try KeychainManager.shared.saveToken(token)
            
            safariViewController?.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                self.delegate?.authDidSucceed(with: token)
                self.authenticationCompletion?(.success(token))
            }
        } catch {
            delegate?.authDidFail(with: .tokenExchangeFailed)
            authenticationCompletion?(.failure(.tokenExchangeFailed))
        }
    }
    
    private func loadTokenFromKeychain() {
        do {
            currentToken = try KeychainManager.shared.getToken()
            isAuthenticated = currentToken != nil
        } catch {
            print("Failed to load token from Keychain: \(error)")
        }
    }
    
    public func logout() {
        do {
            try KeychainManager.shared.deleteToken()
            currentToken = nil
            isAuthenticated = false
        } catch {
            print("Failed to delete token from Keychain: \(error)")
        }
    }
}

extension GitHubAuthManager: SFSafariViewControllerDelegate {
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        delegate?.authDidFail(with: .userCancelled)
        authenticationCompletion?(.failure(.userCancelled))
        safariViewController = nil
    }
}

private struct TokenResponse: Codable {
    let access_token: String
    let token_type: String
    let scope: String
    let refresh_token: String?
    let expires_in: TimeInterval?
}
