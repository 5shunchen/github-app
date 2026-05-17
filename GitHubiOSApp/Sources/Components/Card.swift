//
//  Card.swift
//  GitHubiOSApp
//
//  Created by Dev B on 2026/05/17.
//

import SwiftUI

enum GHCardStyle {
    case `default`
    case elevated
    case bordered
}

struct GHCard<Content: View>: View {
    let style: GHCardStyle
    let padding: CGFloat
    let content: Content
    
    init(
        style: GHCardStyle = .default,
        padding: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(padding)
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowY)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: borderWidth)
        )
    }
    
    private var backgroundColor: Color {
        switch style {
        case .default, .elevated:
            return Color(.systemBackground)
        case .bordered:
            return Color(.systemGray6)
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .elevated:
            return Color.black.opacity(0.1)
        default:
            return Color.black.opacity(0.05)
        }
    }
    
    private var shadowRadius: CGFloat {
        switch style {
        case .elevated:
            return 8
        default:
            return 2
        }
    }
    
    private var shadowY: CGFloat {
        switch style {
        case .elevated:
            return 4
        default:
            return 1
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .bordered:
            return Color(.systemGray4)
        default:
            return Color(.systemGray5)
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .bordered:
            return 1
        default:
            return 0.5
        }
    }
}

// MARK: - Repository Card
struct GHRepositoryCard: View {
    let name: String
    let owner: String
    let description: String?
    let stars: Int
    let language: String?
    let languageColor: Color?
    let forks: Int
    let updatedAt: String
    
    var body: some View {
        GHCard {
            VStack(alignment: .leading, spacing: 12) {
                // Header: Owner/Name
                HStack(spacing: 8) {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(.secondary)
                    
                    Text("\(owner)/")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color(red: 35/255, green: 134/255, blue: 54/255))
                    
                    Spacer()
                    
                    Image(systemName: "star")
                        .foregroundColor(.secondary)
                }
                
                // Description
                if let description = description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Footer: Stats
                HStack(spacing: 16) {
                    if let language = language {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(languageColor ?? .gray)
                                .frame(width: 12, height: 12)
                            
                            Text(language)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.secondary)
                        
                        Text(formatNumber(stars))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "tuningfork")
                            .foregroundColor(.secondary)
                        
                        Text(formatNumber(forks))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(updatedAt)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func formatNumber(_ number: Int) -> String {
        if number >= 1000000 {
            return String(format: "%.1fm", Double(number) / 1000000)
        } else if number >= 1000 {
            return String(format: "%.1fk", Double(number) / 1000)
        }
        return "\(number)"
    }
}

// MARK: - User Card
struct GHUserCard: View {
    let avatarURL: String
    let username: String
    let name: String?
    let bio: String?
    let followers: Int
    let following: Int
    
    var body: some View {
        GHCard {
            HStack(spacing: 12) {
                // Avatar
                AsyncImage(url: URL(string: avatarURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(username)
                        .font(.headline.weight(.semibold))
                    
                    if let name = name {
                        Text(name)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let bio = bio, !bio.isEmpty {
                        Text(bio)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    HStack(spacing: 12) {
                        Text("\(followers) followers")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("\(following) following")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Preview
struct GHCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 16) {
                GHCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Default Card")
                            .font(.headline)
                        Text("This is a default card style")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                GHCard(style: .elevated) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Elevated Card")
                            .font(.headline)
                        Text("This card has more shadow")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                GHRepositoryCard(
                    name: "openclaw",
                    owner: "developer",
                    description: "A powerful AI assistant framework for iOS",
                    stars: 12500,
                    language: "Swift",
                    languageColor: .orange,
                    forks: 1200,
                    updatedAt: "2 days ago"
                )
                
                GHUserCard(
                    avatarURL: "https://avatars.githubusercontent.com/u/123456?v=4",
                    username: "johndoe",
                    name: "John Doe",
                    bio: "iOS Developer | Swift Enthusiast",
                    followers: 5000,
                    following: 300
                )
            }
            .padding()
        }
        .background(Color(.systemGray6))
        .previewLayout(.sizeThatFits)
    }
}
