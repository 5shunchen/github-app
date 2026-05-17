//
//  NetworkError.swift
//  GitHubiOS
//
//  Created by iOS Architect on 5/17/26.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case decodingError(Error)
    case encodingError(Error)
    case noToken
    case underlying(Error)
    case cancelled
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .statusCode(let code):
            return "Status code error: \(code)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Encoding error: \(error.localizedDescription)"
        case .noToken:
            return "No authentication token"
        case .underlying(let error):
            return error.localizedDescription
        case .cancelled:
            return "Request cancelled"
        }
    }
}
