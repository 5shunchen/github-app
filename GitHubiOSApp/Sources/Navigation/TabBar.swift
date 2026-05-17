//
//  TabBar.swift
//  GitHubiOSApp
//
//  Created by Dev B on 2026/05/17.
//

import SwiftUI

// MARK: - Tab Type
enum TabType: Int, CaseIterable {
    case home
    case explore
    case notifications
    case profile
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .explore: return "Explore"
        case .notifications: return "Notifications"
        case .profile: return "Profile"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .explore: return "safari"
        case .notifications: return "bell"
        case .profile: return "person"
        }
    }
    
    var selectedIcon: String {
        switch self {
        case .home: return "house.fill"
        case .explore: return "safari.fill"
        case .notifications: return "bell.fill"
        case .profile: return "person.fill"
        }
    }
}

// MARK: - Custom Tab Bar
struct GHTabBar: View {
    @Binding var selectedTab: TabType
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabType.allCases, id: \.self) { tab in
                TabButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    animation: animation
                ) {
                    selectedTab = tab
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: -2)
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let tab: TabType
    let isSelected: Bool
    let animation: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? Color(red: 35/255, green: 134/255, blue: 54/255) : .gray)
                
                Text(tab.title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? Color(red: 35/255, green: 134/255, blue: 54/255) : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
            .overlay(
                VStack {
                    if isSelected {
                        Capsule()
                            .fill(Color(red: 35/255, green: 134/255, blue: 54/255))
                            .frame(width: 24, height: 3)
                            .matchedGeometryEffect(id: "tabIndicator", in: animation)
                    } else {
                        Color.clear.frame(height: 3)
                    }
                },
                alignment: .top
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Tab Container
struct GHTabContainer<Content: View>: View {
    @Binding var selectedTab: TabType
    let content: Content
    
    init(selectedTab: Binding<TabType>, @ViewBuilder content: () -> Content) {
        self._selectedTab = selectedTab
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                content
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            GHTabBar(selectedTab: $selectedTab)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: - Navigation Bar
struct GHNavigationBar: View {
    let title: String
    let titleDisplayMode: TitleDisplayMode
    let leadingItem: AnyView?
    let trailingItem: AnyView?
    
    enum TitleDisplayMode {
        case large
        case inline
    }
    
    init<Leading: View, Trailing: View>(
        title: String,
        titleDisplayMode: TitleDisplayMode = .large,
        @ViewBuilder leadingItem: () -> Leading = { EmptyView() },
        @ViewBuilder trailingItem: () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.titleDisplayMode = titleDisplayMode
        
        let leading = leadingItem()
        self.leadingItem = leading is EmptyView ? nil : AnyView(leading)
        
        let trailing = trailingItem()
        self.trailingItem = trailing is EmptyView ? nil : AnyView(trailing)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if titleDisplayMode == .large {
                HStack(spacing: 16) {
                    if let leadingItem = leadingItem {
                        leadingItem
                    }
                    
                    Spacer()
                    
                    if let trailingItem = trailingItem {
                        trailingItem
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                
                Text(title)
                    .font(.largeTitle.weight(.bold))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            } else {
                HStack(spacing: 16) {
                    if let leadingItem = leadingItem {
                        leadingItem
                    }
                    
                    Text(title)
                        .font(.headline.weight(.semibold))
                    
                    Spacer()
                    
                    if let trailingItem = trailingItem {
                        trailingItem
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Back Button
struct GHBackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(red: 35/255, green: 134/255, blue: 54/255))
                .frame(width: 32, height: 32)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}

// MARK: - Navigation Wrapper
struct GHNavigationWrapper<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        NavigationView {
            content
                .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Preview
struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        GHNavigationWrapper {
            GHTabContainer(selectedTab: .constant(.home)) {
                TabContentView(selectedTab: .home)
            }
        }
        .previewDisplayName("Tab Bar")
        
        VStack(spacing: 0) {
            GHNavigationBar(
                title: "Home",
                titleDisplayMode: .large,
                trailingItem: {
                    GHIconButton(icon: "gear", size: 18, action: {})
                }
            )
            
            Spacer()
        }
        .previewDisplayName("Large Title Navigation")
        
        VStack(spacing: 0) {
            GHNavigationBar(
                title: "Repository",
                titleDisplayMode: .inline,
                leadingItem: {
                    GHBackButton(action: {})
                },
                trailingItem: {
                    GHIconButton(icon: "square.and.arrow.up", size: 18, action: {})
                }
            )
            
            Spacer()
        }
        .previewDisplayName("Inline Navigation")
    }
}

// Helper for preview
struct TabContentView: View {
    let selectedTab: TabType
    
    var body: some View {
        VStack {
            GHNavigationBar(title: selectedTab.title, titleDisplayMode: .large)
            Spacer()
            Text(selectedTab.title)
                .font(.largeTitle)
            Spacer()
        }
        .background(Color(.systemGray6))
    }
}
