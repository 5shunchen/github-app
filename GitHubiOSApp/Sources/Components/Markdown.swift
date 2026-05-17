//
//  Markdown.swift
//  GitHubiOSApp
//
//  Created by Dev B on 2026/05/17.
//

import SwiftUI
import AttributedString

// MARK: - Markdown Parser
enum MarkdownElement {
    case header(level: Int, text: String)
    case paragraph(text: String)
    case listItem(text: String, ordered: Bool, index: Int)
    case codeBlock(text: String, language: String?)
    case blockquote(text: String)
    case horizontalRule
    case link(text: String, url: String)
    case image(alt: String, url: String)
}

class MarkdownParser {
    static func parse(_ markdown: String) -> [MarkdownElement] {
        var elements: [MarkdownElement] = []
        let lines = markdown.components(separatedBy: .newlines)
        
        var inCodeBlock = false
        var codeBlockText = ""
        var codeLanguage: String?
        
        for line in lines {
            // Code block detection
            if line.hasPrefix("```") {
                if inCodeBlock {
                    elements.append(.codeBlock(text: codeBlockText.trimmingCharacters(in: .whitespacesAndNewlines), language: codeLanguage))
                    inCodeBlock = false
                    codeBlockText = ""
                    codeLanguage = nil
                } else {
                    inCodeBlock = true
                    codeLanguage = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                }
                continue
            }
            
            if inCodeBlock {
                codeBlockText += line + "\n"
                continue
            }
            
            // Header
            if line.hasPrefix("###### ") {
                elements.append(.header(level: 6, text: String(line.dropFirst(7))))
                continue
            }
            if line.hasPrefix("##### ") {
                elements.append(.header(level: 5, text: String(line.dropFirst(6))))
                continue
            }
            if line.hasPrefix("#### ") {
                elements.append(.header(level: 4, text: String(line.dropFirst(5))))
                continue
            }
            if line.hasPrefix("### ") {
                elements.append(.header(level: 3, text: String(line.dropFirst(4))))
                continue
            }
            if line.hasPrefix("## ") {
                elements.append(.header(level: 2, text: String(line.dropFirst(3))))
                continue
            }
            if line.hasPrefix("# ") {
                elements.append(.header(level: 1, text: String(line.dropFirst(2))))
                continue
            }
            
            // Horizontal rule
            if line == "---" || line == "***" || line == "___" {
                elements.append(.horizontalRule)
                continue
            }
            
            // Blockquote
            if line.hasPrefix("> ") {
                elements.append(.blockquote(text: String(line.dropFirst(2))))
                continue
            }
            
            // Unordered list
            if line.hasPrefix("- ") || line.hasPrefix("* ") || line.hasPrefix("+ ") {
                let text = String(line.dropFirst(2))
                elements.append(.listItem(text: text, ordered: false, index: 0))
                continue
            }
            
            // Ordered list
            let orderedListRegex = try? NSRegularExpression(pattern: "^\\d+\\.\\s", options: [])
            if let match = orderedListRegex?.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)) {
                let prefix = (line as NSString).substring(with: match.range)
                let text = String(line.dropFirst(prefix.count))
                let index = Int(prefix.trimmingCharacters(in: CharacterSet(charactersIn: ". ").inverted)) ?? 0
                elements.append(.listItem(text: text, ordered: true, index: index))
                continue
            }
            
            // Paragraph
            if !line.trimmingCharacters(in: .whitespaces).isEmpty {
                elements.append(.paragraph(text: line))
            }
        }
        
        return elements
    }
    
    static func parseInlineElements(_ text: String) -> AttributedString {
        var result = AttributedString(text)
        
        // Bold: **text** or __text__
        let boldPattern = "(\\*\\*|__)(.*?)\\1"
        applyPattern(boldPattern, to: &result) { range in
            result[range].inlinePresentationIntent = .stronglyEmphasized
        }
        
        // Italic: *text* or _text_
        let italicPattern = "(\\*|_)(.*?)\\1"
        applyPattern(italicPattern, to: &result) { range in
            result[range].inlinePresentationIntent = .emphasized
        }
        
        // Code: `text`
        let codePattern = "`([^`]+)`"
        applyPattern(codePattern, to: &result) { range in
            result[range].inlinePresentationIntent = .code
        }
        
        // Link: [text](url)
        let linkPattern = "\\[([^\\]]+)\\]\\(([^\\)]+)\\)"
        if let regex = try? NSRegularExpression(pattern: linkPattern, options: []) {
            let nsString = NSString(string: text)
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
            
            for match in matches.reversed() {
                if match.numberOfRanges == 3 {
                    let linkText = nsString.substring(with: match.range(at: 1))
                    let urlString = nsString.substring(with: match.range(at: 2))
                    
                    if let range = Range(match.range, in: result) {
                        let replacement = AttributedString(linkText)
                        replacement[replacement.startIndex..<replacement.endIndex].link = URL(string: urlString)
                        replacement[replacement.startIndex..<replacement.endIndex].foregroundColor = Color(red: 35/255, green: 134/255, blue: 54/255)
                        result.replaceSubrange(range, with: replacement)
                    }
                }
            }
        }
        
        return result
    }
    
    private static func applyPattern(_ pattern: String, to attributedString: inout AttributedString, modifier: (Range<AttributedString.Index>) -> Void) {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return }
        
        let string = String(attributedString.characters)
        let matches = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))
        
        for match in matches.reversed() {
            if match.numberOfRanges >= 2, let contentRange = Range(match.range(at: 2), in: attributedString) {
                modifier(contentRange)
            }
        }
    }
}

// MARK: - Markdown View
struct GHMarkdownView: View {
    let markdown: String
    private let elements: [MarkdownElement]
    
    init(markdown: String) {
        self.markdown = markdown
        self.elements = MarkdownParser.parse(markdown)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(elements.indices, id: \.self) { index in
                renderElement(elements[index])
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func renderElement(_ element: MarkdownElement) -> some View {
        switch element {
        case .header(let level, let text):
            Text(MarkdownParser.parseInlineElements(text))
                .font(fontForHeaderLevel(level))
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
        case .paragraph(let text):
            Text(MarkdownParser.parseInlineElements(text))
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
        case .listItem(let text, let ordered, let index):
            HStack(alignment: .top, spacing: 8) {
                Text(ordered ? "\(index)." : "•")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(width: ordered ? 24 : 16, alignment: .trailing)
                
                Text(MarkdownParser.parseInlineElements(text))
                    .font(.body)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
            
        case .codeBlock(let text, let language):
            VStack(alignment: .leading, spacing: 8) {
                if let language = language, !language.isEmpty {
                    Text(language)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(text)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.primary)
                        .padding(12)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
        case .blockquote(let text):
            HStack(spacing: 12) {
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(width: 4)
                
                Text(MarkdownParser.parseInlineElements(text))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
            .padding(.vertical, 4)
            
        case .horizontalRule:
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(height: 1)
            
        case .link(let text, let url):
            Link(destination: URL(string: url) ?? URL(string: "https://github.com")!) {
                Text(text)
                    .foregroundColor(Color(red: 35/255, green: 134/255, blue: 54/255))
            }
            
        case .image(let alt, let url):
            AsyncImage(url: URL(string: url)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(8)
                    
                case .failure:
                    VStack {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text(alt)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                @unknown default:
                    EmptyView()
                }
            }
        }
    }
    
    private func fontForHeaderLevel(_ level: Int) -> Font {
        switch level {
        case 1: return .largeTitle
        case 2: return .title
        case 3: return .title2
        case 4: return .title3
        case 5: return .headline
        case 6: return .subheadline
        default: return .body
        }
    }
}

// MARK: - Issue / PR Body View
struct GHIssueBodyView: View {
    let title: String
    let state: String
    let stateStyle: GHStateBadge.BadgeStyle
    let author: String
    let createdAt: String
    let body: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Title
                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Metadata
                HStack(spacing: 12) {
                    GHStateBadge(style: stateStyle, text: state)
                    
                    Text(author)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.primary)
                    
                    Text(createdAt)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Body
                GHMarkdownView(markdown: body)
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Preview
struct Markdown_Previews: PreviewProvider {
    static let sampleMarkdown = """
# Welcome to GitHub iOS

This is a **sample** Markdown document with *various* elements.

## Features

- Native SwiftUI rendering
- Support for **bold** and *italic* text
- `inline code` support
- Links like [GitHub](https://github.com)

### Code Block

```swift
struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
    }
}
```

> Important note: This is a blockquote that can span multiple lines and contain *formatted* text.

---

## Ordered List

1. First item
2. Second item
3. Third item

## Conclusion

Thank you for using our app!
"""
    
    static var previews: some View {
        NavigationView {
            GHIssueBodyView(
                title: "Add Markdown rendering support for issue and PR descriptions",
                state: "Open",
                stateStyle: .success,
                author: "@johndoe",
                createdAt: "opened 2 days ago",
                body: sampleMarkdown
            )
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
        }
        .previewDisplayName("Markdown Preview")
    }
}
