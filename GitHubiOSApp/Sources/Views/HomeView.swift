//
//  HomeView.swift
//  GitHubiOSApp
//
//  Created by Dev B on 2026/05/17.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Stories / Highlights
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<5) { index in
                            StoryItem(index: index)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                // My Repositories
                GHSectionHeader(title: "My Repositories", showAll: true)
                
                GHList {
                    ForEach(0..<3) { index in
                        GHRepositoryRow(
                            name: "repo-\(index)",
                            owner: "myusername",
                            description: "My awesome project repository",
                            stars: 100 + index * 50,
                            language: "Swift",
                            languageColor: .orange,
                            action: {}
                        )
                    }
                }
                .padding(.horizontal, 16)
                
                // Recent Activity
                GHSectionHeader(title: "Recent Activity", showAll: true)
                
                GHList {
                    ForEach(0..<4) { index in
                        ActivityItem(index: index)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 16)
        }
        .background(Color(.systemGray6))
    }
}

// MARK: - Story Item
struct StoryItem: View {
    let index: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(LinearGradient(
                    colors: [Color(red: 35/255, green: 134/255, blue: 54/255), .blue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                )
            
            Text("User \(index)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Activity Item
struct ActivityItem: View {
    let index: Int
    
    var body: some View {
        GHListRow(
            icon: activityIcon,
            iconColor: activityColor,
            content: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("user\(index) \(activityAction)")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Text("repo-\(index)/project")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(index + 1)h ago")
                        .font(.caption2)
                        .foregroundColor(.tertiaryLabel)
                }
            }
        )
    }
    
    private var activityIcon: String {
        let icons = ["star.fill", "tuningfork", "pencil", "checkmark.circle.fill"]
        return icons[index % icons.count]
    }
    
    private var activityColor: Color {
        let colors: [Color] = [.yellow, .blue, .orange, .green]
        return colors[index % colors.count]
    }
    
    private var activityAction: String {
        let actions = ["starred a repository", "forked a repository", "pushed commits", "merged a PR"]
        return actions[index % actions.count]
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        GHNavigationWrapper {
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
        }
    }
}
