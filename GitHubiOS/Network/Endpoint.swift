//
//  Endpoint.swift
//  GitHubiOS
//
//  Created by iOS Architect on 5/17/26.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

protocol EndpointProtocol {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
}

enum Endpoint: EndpointProtocol {
    // MARK: - Repositories
    case getRepositories(perPage: Int, page: Int)
    case searchRepositories(query: String, perPage: Int, page: Int)
    case getRepository(owner: String, name: String)
    
    // MARK: - Authentication
    case authenticate(code: String)
    
    // MARK: - User
    case getCurrentUser
    
    // MARK: - EndpointProtocol
    var baseURL: String {
        return "https://api.github.com"
    }
    
    var path: String {
        switch self {
        case .getRepositories:
            return "/user/repos"
        case .searchRepositories:
            return "/search/repositories"
        case .getRepository(let owner, let name):
            return "/repos/\(owner)/\(name)"
        case .authenticate:
            return "/login/oauth/access_token"
        case .getCurrentUser:
            return "/user"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getRepositories, .searchRepositories, .getRepository, .getCurrentUser:
            return .get
        case .authenticate:
            return .post
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .authenticate:
            return ["Accept": "application/json"]
        default:
            return nil
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .getRepositories(let perPage, let page):
            return ["per_page": perPage, "page": page]
        case .searchRepositories(let query, let perPage, let page):
            return ["q": query, "per_page": perPage, "page": page]
        case .getRepository, .getCurrentUser:
            return nil
        case .authenticate(let code):
            return [
                "client_id": "YOUR_CLIENT_ID",
                "client_secret": "YOUR_CLIENT_SECRET",
                "code": code
            ]
        }
    }
    
    func makeURLRequest() throws -> URLRequest {
        guard let url = URL(string: baseURL)?.appendingPathComponent(path) else {
            throw NetworkError.invalidURL
        }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        if method == .get, let parameters = parameters {
            urlComponents?.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
        }
        
        guard let finalURL = urlComponents?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        
        headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        if method != .get, let parameters = parameters {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                throw NetworkError.encodingError(error)
            }
        }
        
        return request
    }
}
