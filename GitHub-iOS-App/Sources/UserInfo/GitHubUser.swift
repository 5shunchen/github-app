//
//  GitHubUser.swift
//  GitHubApp
//
//  Created by C on 2026/05/17.
//

import Foundation

public struct GitHubUser: Codable, Identifiable {
    public let id: Int
    public let login: String
    public let avatarURL: String
    public let name: String?
    public let bio: String?
    public let company: String?
    public let location: String?
    public let blog: String?
    public let email: String?
    public let followers: Int
    public let following: Int
    public let publicRepos: Int
    public let publicGists: Int
    public let createdAt: Date
    public let updatedAt: Date
    public let htmlURL: String
    
    enum CodingKeys: String, CodingKey {
        case id, login, name, bio, company, location, blog, email
        case followers, following
        case avatarURL = "avatar_url"
        case publicRepos = "public_repos"
        case publicGists = "public_gists"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case htmlURL = "html_url"
    }
    
    public init(
        id: Int,
        login: String,
        avatarURL: String,
        name: String?,
        bio: String?,
        company: String?,
        location: String?,
        blog: String?,
        email: String?,
        followers: Int,
        following: Int,
        publicRepos: Int,
        publicGists: Int,
        createdAt: Date,
        updatedAt: Date,
        htmlURL: String
    ) {
        self.id = id
        self.login = login
        self.avatarURL = avatarURL
        self.name = name
        self.bio = bio
        self.company = company
        self.location = location
        self.blog = blog
        self.email = email
        self.followers = followers
        self.following = following
        self.publicRepos = publicRepos
        self.publicGists = publicGists
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.htmlURL = htmlURL
    }
    
    public var displayName: String {
        name ?? login
    }
    
    public var formattedJoinDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return "Joined \(formatter.string(from: createdAt))"
    }
    
    public var formattedFollowers: String {
        formatNumber(followers)
    }
    
    public var formattedFollowing: String {
        formatNumber(following)
    }
    
    public var formattedRepos: String {
        formatNumber(publicRepos)
    }
    
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

public struct GitHubRepository: Codable, Identifiable {
    public let id: Int
    public let name: String
    public let fullName: String
    public let description: String?
    public let stargazersCount: Int
    public let forksCount: Int
    public let language: String?
    public let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, language
        case fullName = "full_name"
        case stargazersCount = "stargazers_count"
        case forksCount = "forks_count"
        case updatedAt = "updated_at"
    }
}
