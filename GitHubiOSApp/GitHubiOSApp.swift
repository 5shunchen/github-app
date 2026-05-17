//
//  GitHubiOSApp.swift
//  GitHubiOSApp
//
//  Created by Dev B on 2026/05/17.
//

import SwiftUI

@main
struct GitHubiOSApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: TabType = .home
    
    var body: some View {
        GHTabContainer(selectedTab: $selectedTab) {
            switch selectedTab {
            case .home:
                HomeTabView()
            case .explore:
                ExploreTabView()
            case .notifications:
                NotificationsTabView()
            case .profile:
                ProfileTabView()
            }
        }
    }
}

// MARK: - Tab Views
struct HomeTabView: View {
    var body: some View {
        VStack(spacing: 0) {
            GHNavigationBar(
                title: "Home",
                titleDisplayMode: .large,
                trailingItem: {
                    GHIconButton(icon: "plus", size: 18, action: {})
                }
            )
            HomeView()
        }
        .background(Color(.systemGray6))
    }
}

struct ExploreTabView: View {
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            GHNavigationBar(title: "Explore", titleDisplayMode: .large)
            
            ScrollView {
                VStack(spacing: 16) {
                    GHSearchBar(text: $searchText, placeholder: "Search repositories, users, issues...")
                        .padding(.horizontal, 16)
                    
                    GHSectionHeader(title: "Trending Repositories", showAll: true)
                    
                    GHList {
                        ForEach(0..<5) { index in
                            GHRepositoryRow(
                                name: "trending-\(index)",
                                owner: "org-\(index)",
                                description: "A very popular open source project",
                                stars: 50000 - index * 5000,
                                language: ["Swift", "Python", "TypeScript", "Rust", "Go"][index],
                                languageColor: [.orange, .blue, .blue, .orange, .cyan][index],
                                action: {}
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    GHSectionHeader(title: "Developers to Follow", showAll: true)
                    
                    GHList {
                        ForEach(0..<3) { index in
                            GHUserRow(
                                avatarURL: "https://avatars.githubusercontent.com/u/\(100000 + index * 1000)?v=4",
                                username: "dev-\(index)",
                                name: "Developer \(index)",
                                bio: "Open source contributor",
                                action: {}
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 16)
            }
        }
        .background(Color(.systemGray6))
    }
}

struct NotificationsTabView: View {
    var body: some View {
        VStack(spacing: 0) {
            GHNavigationBar(title: "Notifications", titleDisplayMode: .large)
            
            ScrollView {
                VStack(spacing: 16) {
                    GHSearchScopeBar(selectedScope: .constant(0), scopes: ["All", "Unread", "Participating"])
                        .padding(.horizontal, 16)
                    
                    GHList {
                        ForEach(0..<8) { index in
                            NotificationItem(index: index)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 16)
            }
        }
        .background(Color(.systemGray6))
    }
}

struct ProfileTabView: View {
    var body: some View {
        VStack(spacing: 0) {
            GHNavigationBar(
                title: "Profile",
                titleDisplayMode: .large,
                trailingItem: {
                    GHIconButton(icon: "gear", size: 18, action: {})
                }
            )
            
            ScrollView {
                VStack(spacing: 16) {
                    // Profile Card
                    GHCard {
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [Color(red: 35/255, green: 134/255, blue: 54/255), .blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(.white)
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("John Developer")
                                        .font(.title2.weight(.bold))
                                    
                                    Text("@johndeveloper")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text("iOS Developer • SwiftUI Enthusiast")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            
                            HStack(spacing: 32) {
                                ProfileStat(value: "127", label: "Repos")
                                ProfileStat(value: "1.2k", label: "Followers")
                                ProfileStat(value: "342", label: "Following")
                                ProfileStat(value: "45", label: "Stars")
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Pinned Repositories
                    GHSectionHeader(title: "Pinned Repositories", showAll: true)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0..<4) { index in
                                GHRepositoryCard(
                                    name: "project-\(index)",
                                    owner: "johndeveloper",
                                    description: "My awesome open source project",
                                    stars: 1000 + index * 500,
                                    language: "Swift",
                                    languageColor: .orange,
                                    forks: 100 + index * 50,
                                    updatedAt: "\(index + 1)d ago"
                                )
                                .frame(width: 280)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Contribution Graph
                    GHCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Contributions")
                                .font(.headline.weight(.semibold))
                            
                            ContributionGraph()
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 16)
            }
        }
        .background(Color(.systemGray6))
    }
}

// MARK: - Helper Views
struct NotificationItem: View {
    let index: Int
    
    var body: some View {
        GHListRow(
            icon: notificationIcon,
            iconColor: notificationColor,
            content: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("org-\(index)/repo-\(index)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                    
                    Text("New comment on issue #\(100 + index): \(notificationTitle)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    Text("\(index + 1)h ago")
                        .font(.caption2)
                        .foregroundColor(.tertiaryLabel)
                }
            }
        )
    }
    
    private var notificationIcon: String {
        let icons = ["bell.fill", "envelope.fill", "checkmark.circle.fill", "exclamationmark.circle.fill"]
        return icons[index % icons.count]
    }
    
    private var notificationColor: Color {
        let colors: [Color] = [.blue, .orange, .green, .red]
        return colors[index % colors.count]
    }
    
    private var notificationTitle: String {
        let titles = ["Feature request", "Bug report", "Review requested", "Security alert"]
        return titles[index % titles.count]
    }
}

struct ProfileStat: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct ContributionGraph: View {
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 52)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(0..<364) { index in
                Rectangle()
                    .fill(colorForContribution(index: index))
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(2)
            }
        }
    }
    
    private func colorForContribution(index: Int) -> Color {
        let level = index % 5
        switch level {
        case 0: return Color(.systemGray5)
        case 1: return Color(red: 35/255, green: 134/255, blue: 54/255).opacity(0.2)
        case 2: return Color(red: 35/255, green: 134/255, blue: 54/255).opacity(0.4)
        case 3: return Color(red: 35/255, green: 134/255, blue: 54/255).opacity(0.6)
        case 4: return Color(red: 35/255, green: 134/255, blue: 54/255)
        default: return Color(.systemGray5)
        }
    }
}

// MARK: - Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .previewDisplayName("Main App")
    }
}
