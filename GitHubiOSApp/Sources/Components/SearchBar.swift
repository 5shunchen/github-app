//
//  SearchBar.swift
//  GitHubiOSApp
//
//  Created by Dev B on 2026/05/17.
//

import SwiftUI

// MARK: - Search Bar
struct GHSearchBar: View {
    @Binding var text: String
    let placeholder: String
    let onCommit: (() -> Void)?
    let onCancel: (() -> Void)?
    let showCancel: Bool
    
    @FocusState private var isFocused: Bool
    
    init(
        text: Binding<String>,
        placeholder: String = "Search",
        showCancel: Bool = true,
        onCommit: (() -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.showCancel = showCancel
        self.onCommit = onCommit
        self.onCancel = onCancel
    }
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                
                TextField(placeholder, text: $text)
                    .font(.body)
                    .focused($isFocused)
                    .onSubmit {
                        onCommit?()
                    }
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            if showCancel && isFocused {
                Button("Cancel") {
                    text = ""
                    isFocused = false
                    onCancel?()
                }
                .font(.body.weight(.medium))
                .foregroundColor(Color(red: 35/255, green: 134/255, blue: 54/255))
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Search Scope Bar
struct GHSearchScopeBar: View {
    @Binding var selectedScope: Int
    let scopes: [String]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(scopes.indices, id: \.self) { index in
                Button(action: {
                    selectedScope = index
                }) {
                    Text(scopes[index])
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(selectedScope == index ? .white : .secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedScope == index ? Color(red: 35/255, green: 134/255, blue: 54/255) : Color.clear)
                        )
                }
            }
        }
        .padding(4)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Search Suggestion
struct GHSearchSuggestion: View {
    let icon: String
    let title: String
    let subtitle: String?
    let action: () -> Void
    
    var body: some View {
        GHListRow(
            icon: icon,
            iconColor: Color(red: 35/255, green: 134/255, blue: 54/255),
            action: action,
            content: {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            },
            trailing: {
                Image(systemName: "arrow.up.left")
                    .font(.system(size: 14))
                    .foregroundColor(.tertiaryLabel)
            }
        )
    }
}

// MARK: - Search Result
struct GHSearchResult<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GHSectionHeader(title: title)
            
            GHList {
                content
            }
        }
    }
}

// MARK: - State Badge
struct GHStateBadge: View {
    let style: BadgeStyle
    let text: String
    
    enum BadgeStyle {
        case success
        case warning
        case error
        case info
        case neutral
        
        var color: Color {
            switch self {
            case .success: return Color(red: 35/255, green: 134/255, blue: 54/255)
            case .warning: return .orange
            case .error: return Color(red: 207/255, green: 34/255, blue: 46/255)
            case .info: return .blue
            case .neutral: return .gray
            }
        }
        
        var backgroundColor: Color {
            color.opacity(0.15)
        }
    }
    
    init(style: BadgeStyle, text: String) {
        self.style = style
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundColor(style.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(style.backgroundColor)
            .cornerRadius(12)
    }
}

// MARK: - Label Value Pair
struct GHLabelValue: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

// MARK: - Statistics Card
struct GHStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        GHCard(padding: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.15))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)
                    
                    Text(label)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Preview
struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            GHSearchBar(text: .constant(""), placeholder: "Search repositories")
            
            GHSearchBar(text: .constant("swift"), placeholder: "Search")
            
            GHSearchScopeBar(selectedScope: .constant(0), scopes: ["All", "Repositories", "Users", "Issues"])
            
            GHList {
                GHSearchSuggestion(
                    icon: "bookmark.fill",
                    title: "swiftui",
                    subtitle: "apple/swiftui",
                    action: {}
                )
                GHSearchSuggestion(
                    icon: "person.fill",
                    title: "John Doe",
                    subtitle: "@johndoe",
                    action: {}
                )
            }
            
            HStack(spacing: 8) {
                GHStateBadge(style: .success, text: "Open")
                GHStateBadge(style: .warning, text: "Pending")
                GHStateBadge(style: .error, text: "Closed")
                GHStateBadge(style: .info, text: "Draft")
            }
            
            HStack(spacing: 8) {
                GHStatCard(value: "12.5k", label: "Stars", icon: "star.fill", color: .yellow)
                GHStatCard(value: "1.2k", label: "Forks", icon: "tuningfork", color: .blue)
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
