//
//  UserService.swift
//  GitHubApp
//
//  Created by C on 2026/05/17.
//

import Foundation
import UIKit

public final class UserService {
    public static let shared = UserService()
    
    private init() {}
    
    public func fetchCurrentUser() async throws -> GitHubUser {
        return try await GitHubAPIClient.shared.request("/user")
    }
    
    public func fetchUser(login: String) async throws -> GitHubUser {
        return try await GitHubAPIClient.shared.request("/users/\(login)")
    }
    
    public func fetchUserRepositories(login: String, page: Int = 1, perPage: Int = 30) async throws -> [GitHubRepository] {
        return try await GitHubAPIClient.shared.request("/users/\(login)/repos?page=\(page)&per_page=\(perPage)")
    }
    
    public func fetchAvatarImage(url: String) async throws -> UIImage {
        guard let imageURL = URL(string: url) else {
            throw APIError.invalidURL
        }
        
        let data = try await GitHubAPIClient.shared.requestData(imageURL)
        
        guard let image = UIImage(data: data) else {
            throw APIError.invalidResponse
        }
        
        return image
    }
}

public final class ImageCache {
    public static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private let lock = NSLock()
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024
    }
    
    public func getImage(forKey key: String) -> UIImage? {
        lock.lock()
        defer { lock.unlock() }
        return cache.object(forKey: key as NSString)
    }
    
    public func setImage(_ image: UIImage, forKey key: String) {
        lock.lock()
        defer { lock.unlock() }
        let cost = Int(image.size.width * image.size.height * image.scale * image.scale)
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }
    
    public func removeImage(forKey key: String) {
        lock.lock()
        defer { lock.unlock() }
        cache.removeObject(forKey: key as NSString)
    }
    
    public func clearCache() {
        lock.lock()
        defer { lock.unlock() }
        cache.removeAllObjects()
    }
}

extension UIImageView {
    public func loadImage(from urlString: String, placeholder: UIImage? = nil) -> Task<Void, Never> {
        if let cachedImage = ImageCache.shared.getImage(forKey: urlString) {
            self.image = cachedImage
            return Task {}
        }
        
        self.image = placeholder
        
        return Task {
            do {
                let image = try await UserService.shared.fetchAvatarImage(url: urlString)
                ImageCache.shared.setImage(image, forKey: urlString)
                await MainActor.run {
                    self.image = image
                }
            } catch {
                print("Failed to load image: \(error)")
            }
        }
    }
}
