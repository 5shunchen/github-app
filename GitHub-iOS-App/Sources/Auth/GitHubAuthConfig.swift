//
//  GitHubAuthConfig.swift
//  GitHubApp
//
//  Created by C on 2026/05/17.
//

import Foundation

public struct GitHubAuthConfig {
    public let clientId: String
    public let clientSecret: String
    public let redirectUri: String
    public let scopes: [String]
    
    public init(
        clientId: String,
        clientSecret: String,
        redirectUri: String,
        scopes: [String] = ["user", "repo", "notifications"]
    ) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectUri = redirectUri
        self.scopes = scopes
    }
    
    public var authorizeURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "github.com"
        components.path = "/login/oauth/authorize"
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "scope", value: scopes.joined(separator: " ")),
            URLQueryItem(name: "state", value: UUID().uuidString)
        ]
        return components.url!
    }
}
