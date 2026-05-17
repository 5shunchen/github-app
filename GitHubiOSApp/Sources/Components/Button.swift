//
//  Button.swift
//  GitHubiOSApp
//
//  Created by Dev B on 2026/05/17.
//

import SwiftUI

enum GHButtonStyle {
    case primary
    case secondary
    case danger
    case plain
}

struct GHButton: View {
    let title: String
    let style: GHButtonStyle
    let icon: String?
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    init(
        title: String,
        style: GHButtonStyle = .primary,
        icon: String? = nil,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.icon = icon
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if !isLoading && isEnabled {
                action()
            }
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.subheadline.weight(.semibold))
                    }
                    
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1.0 : 0.5)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return Color(red: 35/255, green: 134/255, blue: 54/255) // GitHub green
        case .secondary:
            return Color(.systemGray6)
        case .danger:
            return Color(red: 207/255, green: 34/255, blue: 46/255)
        case .plain:
            return .clear
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .danger:
            return .white
        case .secondary:
            return .primary
        case .plain:
            return Color(red: 35/255, green: 134/255, blue: 54/255)
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary, .danger, .plain:
            return .clear
        case .secondary:
            return Color(.systemGray4)
        }
    }
}

// MARK: - Icon Button
struct GHIconButton: View {
    let icon: String
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size, weight: .medium))
                .foregroundColor(.primary)
                .frame(width: size + 16, height: size + 16)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}

// MARK: - Preview
struct GHButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            GHButton(title: "Sign In", style: .primary, icon: "person.fill", action: {})
            GHButton(title: "Continue", style: .secondary, icon: "arrow.right", action: {})
            GHButton(title: "Delete", style: .danger, icon: "trash", action: {})
            GHButton(title: "Learn More", style: .plain, action: {})
            GHButton(title: "Loading", style: .primary, isLoading: true, action: {})
            GHButton(title: "Disabled", style: .primary, isEnabled: false, action: {})
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
