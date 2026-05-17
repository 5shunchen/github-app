//
//  LoadingState.swift
//  GitHubiOSApp
//
//  Created by Dev B on 2026/05/17.
//

import SwiftUI

// MARK: - Loading State
enum LoadingState<Value> {
    case idle
    case loading
    case loaded(Value)
    case empty
    case error(Error)
}

// MARK: - Loading View
struct GHLoadingView: View {
    let style: LoadingStyle
    let message: String?
    
    enum LoadingStyle {
        case fullscreen
        case inline
        case card
    }
    
    init(style: LoadingStyle = .fullscreen, message: String? = nil) {
        self.style = style
        self.message = message
    }
    
    var body: some View {
        switch style {
        case .fullscreen:
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 35/255, green: 134/255, blue: 54/255)))
                    .scaleEffect(1.5)
                
                if let message = message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            
        case .inline:
            HStack(spacing: 12) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 35/255, green: 134/255, blue: 54/255)))
                
                if let message = message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
            
        case .card:
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 35/255, green: 134/255, blue: 54/255)))
                
                if let message = message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
}

// MARK: - Empty State View
struct GHEmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(Color(.systemGray3))
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                GHButton(title: actionTitle, style: .secondary, action: action)
                    .padding(.top, 8)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
    }
}

// MARK: - Error State View
struct GHErrorStateView: View {
    let title: String
    let message: String
    let error: Error?
    let retryAction: () -> Void
    let showRetry: Bool
    
    init(
        title: String = "Something went wrong",
        message: String = "Please try again later",
        error: Error? = nil,
        showRetry: Bool = true,
        retryAction: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.error = error
        self.showRetry = showRetry
        self.retryAction = retryAction
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                if let error = error {
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
            
            if showRetry {
                GHButton(title: "Try Again", style: .primary, icon: "arrow.clockwise", action: retryAction)
                    .padding(.top, 8)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - State Container View
struct GHStateContainer<Value, Content: View>: View {
    let state: LoadingState<Value>
    let loadingMessage: String?
    let emptyConfig: EmptyConfig?
    let retryAction: () -> Void
    let content: (Value) -> Content
    
    struct EmptyConfig {
        let icon: String
        let title: String
        let message: String
        let actionTitle: String?
    }
    
    init(
        state: LoadingState<Value>,
        loadingMessage: String? = nil,
        emptyConfig: EmptyConfig? = nil,
        retryAction: @escaping () -> Void,
        @ViewBuilder content: @escaping (Value) -> Content
    ) {
        self.state = state
        self.loadingMessage = loadingMessage
        self.emptyConfig = emptyConfig
        self.retryAction = retryAction
        self.content = content
    }
    
    var body: some View {
        switch state {
        case .idle, .loading:
            GHLoadingView(message: loadingMessage)
            
        case .loaded(let value):
            content(value)
            
        case .empty:
            GHEmptyStateView(
                icon: emptyConfig?.icon ?? "tray",
                title: emptyConfig?.title ?? "Nothing here",
                message: emptyConfig?.message ?? "Check back later",
                actionTitle: emptyConfig?.actionTitle,
                action: retryAction
            )
            
        case .error(let error):
            GHErrorStateView(
                error: error,
                retryAction: retryAction
            )
        }
    }
}

// MARK: - Pull to Refresh
struct GHPullToRefresh: ViewModifier {
    let action: () async -> Void
    @State private var isRefreshing = false
    @State private var offset: CGFloat = 0
    
    func body(content: Content) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                // Progress indicator
                GeometryReader { geometry in
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 35/255, green: 134/255, blue: 54/255)))
                        .opacity(isRefreshing ? 1.0 : max(0, min(1, offset / 60)))
                        .scaleEffect(isRefreshing ? 1.0 : max(0.5, min(1, offset / 60)))
                        .frame(maxWidth: .infinity)
                        .onChange(of: geometry.frame(in: .global).minY) { newValue in
                            if !isRefreshing {
                                offset = newValue
                            }
                        }
                }
                .frame(height: isRefreshing ? 60 : 0)
                
                content
            }
        }
        .onChange(of: offset) { newValue in
            if newValue > 60 && !isRefreshing {
                isRefreshing = true
                Task {
                    await action()
                    isRefreshing = false
                }
            }
        }
    }
}

extension View {
    func ghPullToRefresh(action: @escaping () async -> Void) -> some View {
        self.modifier(GHPullToRefresh(action: action))
    }
}

// MARK: - Preview
struct LoadingState_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GHLoadingView(style: .fullscreen, message: "Loading...")
                .previewDisplayName("Fullscreen Loading")
            
            GHEmptyStateView(
                icon: "bookmark.slash",
                title: "No repositories",
                message: "Start exploring to find interesting projects",
                actionTitle: "Explore",
                action: {}
            )
            .previewDisplayName("Empty State")
            
            GHErrorStateView(
                title: "Failed to load",
                message: "Please check your internet connection",
                retryAction: {}
            )
            .previewDisplayName("Error State")
            
            VStack(spacing: 16) {
                GHLoadingView(style: .inline, message: "Loading...")
                GHLoadingView(style: .card, message: "Fetching data...")
            }
            .padding()
            .background(Color(.systemGray6))
            .previewDisplayName("Other Loading Styles")
        }
    }
}
