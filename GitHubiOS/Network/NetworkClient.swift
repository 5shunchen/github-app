//
//  NetworkClient.swift
//  GitHubiOS
//
//  Created by iOS Architect on 5/17/26.
//

import Foundation
import Combine

protocol NetworkClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type) -> AnyPublisher<T, NetworkError>
}

final class NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let interceptors: [RequestInterceptor]
    private let decoder: JSONDecoder
    
    init(
        session: URLSession = .shared,
        interceptors: [RequestInterceptor] = [LoggingInterceptor(), AuthInterceptor()],
        decoder: JSONDecoder = .defaultDecoder
    ) {
        self.session = session
        self.interceptors = interceptors
        self.decoder = decoder
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type) -> AnyPublisher<T, NetworkError> {
        var urlRequest: URLRequest
        
        do {
            urlRequest = try endpoint.makeURLRequest()
            
            for interceptor in interceptors {
                try interceptor.intercept(&urlRequest)
            }
        } catch let error as NetworkError {
            return Fail(error: error).eraseToAnyPublisher()
        } catch {
            return Fail(error: .underlying(error)).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                #if DEBUG
                if let httpResponse = response as? HTTPURLResponse {
                    print("📥 Response: Status code \(httpResponse.statusCode)")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("📥 Body: \(responseString)")
                    }
                }
                #endif
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                guard 200..<300 ~= httpResponse.statusCode else {
                    throw NetworkError.statusCode(httpResponse.statusCode)
                }
                
                return data
            }
            .decode(type: T.self, decoder: decoder)
            .mapError { error -> NetworkError in
                if let decodingError = error as? DecodingError {
                    return .decodingError(decodingError)
                } else if let networkError = error as? NetworkError {
                    return networkError
                } else {
                    return .underlying(error)
                }
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - JSONDecoder Default
extension JSONDecoder {
    static var defaultDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
