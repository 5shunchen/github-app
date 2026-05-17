//
//  RequestInterceptor.swift
//  GitHubiOS
//
//  Created by iOS Architect on 5/17/26.
//

import Foundation

protocol RequestInterceptor {
    func intercept(_ request: inout URLRequest) throws
}

// MARK: - Authentication Interceptor
final class AuthInterceptor: RequestInterceptor {
    private let tokenManager: TokenManagerProtocol
    
    init(tokenManager: TokenManagerProtocol = TokenManager.shared) {
        self.tokenManager = tokenManager
    }
    
    func intercept(_ request: inout URLRequest) throws {
        guard let token = tokenManager.getToken() else {
            throw NetworkError.noToken
        }
        
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
    }
}

// MARK: - Logging Interceptor
final class LoggingInterceptor: RequestInterceptor {
    func intercept(_ request: inout URLRequest) throws {
        #if DEBUG
        print("📤 Request: \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "N/A")")
        if let headers = request.allHTTPHeaderFields {
            print("📤 Headers: \(headers)")
        }
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("📤 Body: \(bodyString)")
        }
        #endif
    }
}
