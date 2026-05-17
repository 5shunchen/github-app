//
//  Repository.swift
//  GitHubiOS
//
//  Created by iOS Architect on 5/17/26.
//

import Foundation

struct Repository: Identifiable, Codable {
    let id: Int
    let name: String
    let fullName: String
    let description: String?
    let owner: User
    let stargazersCount: Int
    let forksCount: Int
    let openIssuesCount: Int
    let language: String?
    let createdAt: Date
    let updatedAt: Date
    let htmlUrl: String
    let isPrivate: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, owner, language
        case fullName = "full_name"
        case stargazersCount = "stargazers_count"
        case forksCount = "forks_count"
        case openIssuesCount = "open_issues_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case htmlUrl = "html_url"
        case isPrivate = "private"
    }
}

struct User: Identifiable, Codable {
    let id: Int
    let login: String
    let avatarUrl: String
    let htmlUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id, login
        case avatarUrl = "avatar_url"
        case htmlUrl = "html_url"
    }
}

// MARK: - Search Response
struct SearchRepositoriesResponse: Codable {
    let totalCount: Int
    let items: [Repository]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}
