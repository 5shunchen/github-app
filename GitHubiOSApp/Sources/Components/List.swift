//
//  List.swift
//  GitHubiOSApp
//
//  Created by Dev B on 2026/05/17.
//

import SwiftUI

// MARK: - List Container
struct GHList<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        LazyVStack(spacing: 0) {
            content
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - List Row
struct GHListRow<Content: View, Trailing: View>: View {
    let icon: String?
    let iconColor: Color
    let content: Content
    let trailing: Trailing
    let hasDivider: Bool
    let action: (() -> Void)?
    
    init(
        icon: String? = nil,
        iconColor: Color = .secondary,
        hasDivider: Bool = true,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.content = content()
        self.trailing = trailing()
        self.hasDivider = hasDivider
        self.action = action
    }
    
    var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    rowContent
                }
            } else {
                rowContent
            }
        }
        .overlay(
            Rectangle()
                .frame(height: hasDivider ? 0.5 : 0)
                .foregroundColor(Color(.systemGray5))
                .padding(.leading, icon != nil ? 52 : 16),
            alignment: .bottom
        )
    }
    
    private var rowContent: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                    .frame(width: 24, height: 24)
            }
            
            content
            
            Spacer()
            
            trailing
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

// MARK: - Navigation Row
struct GHNavigationRow<Destination: View>: View {
    let icon: String?
    let iconColor: Color
    let title: String
    let value: String?
    let hasDivider: Bool
    let destination: Destination
    
    init(
        icon: String? = nil,
        iconColor: Color = .secondary,
        title: String,
        value: String? = nil,
        hasDivider: Bool = true,
        @ViewBuilder destination: () -> Destination
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.value = value
        self.hasDivider = hasDivider
        self.destination = destination()
    }
    
    var body: some View {
        NavigationLink(destination: destination) {
            GHListRow(
                icon: icon,
                iconColor: iconColor,
                hasDivider: hasDivider,
                content: {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)
                },
                trailing: {
                    HStack(spacing: 8) {
                        if let value = value {
                            Text(value)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.tertiaryLabel)
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Section Header
struct GHSectionHeader: View {
    let title: String
    let showAll: Bool
    let onShowAll: (() -> Void)?
    
    init(title: String, showAll: Bool = false, onShowAll: (() -> Void)? = nil) {
        self.title = title
        self.showAll = showAll
        self.onShowAll = onShowAll
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            if showAll {
                Button(action: onShowAll ?? {}) {
                    Text("See all")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(Color(red: 35/255, green: 134/255, blue: 54/255))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
}

// MARK: - Repository List Row
struct GHRepositoryRow: View {
    let name: String
    let owner: String
    let description: String?
    let stars: Int
    let language: String?
    let languageColor: Color?
    let action: () -> Void
    
    var body: some View {
        GHListRow(
            icon: "bookmark.fill",
            iconColor: Color(red: 35/255, green: 134/255, blue: 54/255),
            action: action,
            content: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(owner)/\(name)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                    
                    if let description = description, !description.isEmpty {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    HStack(spacing: 12) {
                        if let language = language {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(languageColor ?? .gray)
                                    .frame(width: 10, height: 10)
                                
                                Text(language)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.secondary)
                            
                            Text(formatNumber(stars))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            },
            trailing: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.tertiaryLabel)
            }
        )
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

// MARK: - User List Row
struct GHUserRow: View {
    let avatarURL: String
    let username: String
    let name: String?
    let bio: String?
    let action: () -> Void
    
    var body: some View {
        GHListRow(
            hasDivider: true,
            action: action,
            content: {
                HStack(spacing: 12) {
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
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(username)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.primary)
                        
                        if let name = name {
                            Text(name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let bio = bio, !bio.isEmpty {
                            Text(bio)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            },
            trailing: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.tertiaryLabel)
            }
        )
    }
}

// MARK: - Preview
struct GHList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    GHSectionHeader(title: "Settings")
                    
                    GHList {
                        GHNavigationRow(
                            icon: "person.fill",
                            iconColor: .blue,
                            title: "Profile",
                            destination: { Text("Profile View") }
                        )
                        GHNavigationRow(
                            icon: "bell.fill",
                            iconColor: .red,
                            title: "Notifications",
                            value: "12",
                            destination: { Text("Notifications View") }
                        )
                        GHNavigationRow(
                            icon: "gear",
                            iconColor: .gray,
                            title: "Settings",
                            destination: { Text("Settings View") }
                        )
                    }
                    
                    GHSectionHeader(title: "Popular Repositories", showAll: true)
                    
                    GHList {
                        GHRepositoryRow(
                            name: "openclaw",
                            owner: "developer",
                            description: "A powerful AI assistant framework",
                            stars: 12500,
                            language: "Swift",
                            languageColor: .orange,
                            action: {}
                        )
                        GHRepositoryRow(
                            name: "swiftui",
                            owner: "apple",
                            description: "Apple's modern UI framework",
                            stars: 50000,
                            language: "Swift",
                            languageColor: .orange,
                            action: {}
                        )
                    }
                    
                    GHSectionHeader(title: "Followers")
                    
                    GHList {
                        GHUserRow(
                            avatarURL: "https://avatars.githubusercontent.com/u/123456?v=4",
                            username: "johndoe",
                            name: "John Doe",
                            bio: "iOS Developer",
                            action: {}
                        )
                        GHUserRow(
                            avatarURL: "https://avatars.githubusercontent.com/u/789012?v=4",
                            username: "janedoe",
                            name: "Jane Doe",
                            bio: "Designer",
                            action: {}
                        )
                    }
                }
                .padding()
            }
            .background(Color(.systemGray6))
            .navigationTitle("List Components")
        }
    }
}
