# GitHub iOS App - 暗色主题设计规范

> **Version:** 1.0.0  
> **Theme Name:** GitHub Dark Default  
> **Platform:** iOS 17+

---

## 🎯 设计原则

GitHub 暗色主题基于以下核心原则：

1. **开发者友好**：代码语法高亮在暗色背景下更舒适
2. **减少疲劳**：低对比度设计，适合长时间编码
3. **一致体验**：与 GitHub Web 端暗色主题 1:1 对齐
4. **分层视觉**：通过背景色深浅创建清晰的视觉层级

---

## 🎨 完整色彩系统

### 主色调 Primary Colors

| Token | Hex | RGB | 用途 | 对比度 (白底) |
|-------|-----|-----|------|--------------|
| `primary-green` | `#238636` | 35, 134, 54 | 主按钮、选中状态、成功 | 5.1:1 |
| `primary-green-hover` | `#2EA043` | 46, 160, 67 | 按钮悬停 | 6.2:1 |
| `primary-blue` | `#58A6FF` | 88, 166, 255 | 链接、信息、聚焦边框 | 6.4:1 |
| `primary-purple` | `#A371F7` | 163, 113, 247 | 功能强调、标签 | 7.1:1 |
| `primary-red` | `#F85149` | 248, 81, 73 | 错误、删除 | 6.8:1 |
| `primary-yellow` | `#E3B341` | 227, 179, 65 | 警告、待处理 | 7.8:1 |
| `primary-orange` | `#DB6D28` | 219, 109, 40 | 构建状态 | 5.5:1 |

### 背景色 Background Colors

| Token | Hex | RGB | Alpha | 用途 |
|-------|-----|-----|-------|------|
| `bg-canvas` | `#0D1117` | 13, 17, 23 | 1.0 | 页面主背景 (画布层级) |
| `bg-default` | `#161B22` | 22, 27, 34 | 1.0 | 卡片、弹窗、导航栏 |
| `bg-subtle` | `#21262D` | 33, 38, 45 | 1.0 | 输入框、按钮背景、选中行 |
| `bg-inset` | `#010409` | 1, 4, 9 | 1.0 | 内嵌区域、代码块 |
| `bg-overlay` | `#000000` | 0, 0, 0 | 0.8 | 弹窗遮罩、模糊背景 |
| `bg-backdrop` | `#000000` | 0, 0, 0 | 0.5 | 底部弹窗背景 |

### 文字颜色 Text Colors

| Token | Hex | RGB | 用途 | 对比度 |
|-------|-----|-----|------|--------|
| `text-primary` | `#F0F6FC` | 240, 246, 252 | 主要文字、标题 | 13.5:1 |
| `text-secondary` | `#8B949E` | 139, 148, 158 | 次要文字、描述 | 5.9:1 |
| `text-tertiary` | `#6E7681` | 110, 118, 129 | 辅助文字、占位符 | 4.2:1 |
| `text-placeholder` | `#484F58` | 72, 79, 88 | 输入框占位符 | 2.1:1 |
| `text-disabled` | `#484F58` | 72, 79, 88 | 禁用文字 | 2.1:1 |
| `text-link` | `#58A6FF` | 88, 166, 255 | 链接文字 | 6.4:1 |
| `text-success` | `#3FB950` | 63, 185, 80 | 成功状态 | 7.3:1 |
| `text-warning` | `#E3B341` | 227, 179, 65 | 警告状态 | 7.8:1 |
| `text-danger` | `#F85149` | 248, 81, 73 | 错误状态 | 6.8:1 |
| `text-white` | `#FFFFFF` | 255, 255, 255 | 按钮文字、反白 | 14.0:1 |

### 边框与分割线 Border Colors

| Token | Hex | RGB | 用途 |
|-------|-----|-----|------|
| `border-default` | `#30363D` | 48, 54, 61 | 主要边框、按钮边框 |
| `border-muted` | `#21262D` | 33, 38, 45 | 次要边框、分割线 |
| `border-subtle` | `#3D444D` | 61, 68, 77 | 细微边框、悬停状态 |
| `border-emphasis` | `#8B949E` | 139, 148, 158 | 强调边框 |
| `border-success` | `#238636` | 35, 134, 54 | 成功状态边框 |
| `border-danger` | `#DA3633` | 218, 54, 51 | 错误状态边框 |
| `border-focus` | `#1F6FEB` | 31, 111, 235 | 聚焦状态边框 |

### 阴影 Shadows

| Token | 配置 | 用途 |
|-------|------|------|
| `shadow-sm` | color: #000000, opacity: 0.3, radius: 1, offset: (0, 1) | 细微阴影 |
| `shadow-md` | color: #000000, opacity: 0.4, radius: 3, offset: (0, 2) | 卡片阴影 |
| `shadow-lg` | color: #000000, opacity: 0.5, radius: 8, offset: (0, 4) | 弹窗阴影 |
| `shadow-xl` | color: #000000, opacity: 0.6, radius: 16, offset: (0, 8) | 底部弹窗 |

---

## 🧩 组件暗色主题样式详解

### 1. 按钮 Buttons

#### 主按钮 (Primary Button)

```swift
// 状态样式
Normal:
  Background: #238636
  Text: #FFFFFF
  Border: 1pt #238636

Highlighted:
  Background: #2EA043
  Text: #FFFFFF
  Border: 1pt #2EA043

Disabled:
  Background: #238636 (50% opacity)
  Text: #FFFFFF (50% opacity)
```

#### 次要按钮 (Secondary Button)

```swift
Normal:
  Background: #21262D
  Text: #F0F6FC
  Border: 1pt #30363D

Highlighted:
  Background: #30363D
  Text: #F0F6FC
  Border: 1pt #3D444D
```

#### 危险按钮 (Danger Button)

```swift
Normal:
  Background: transparent
  Text: #F85149
  Border: 1pt #30363D

Highlighted:
  Background: #DA3633
  Text: #FFFFFF
  Border: 1pt #F85149
```

### 2. 输入框 Text Field

```swift
Normal:
  Background: #0D1117
  Text: #F0F6FC
  Placeholder: #6E7681
  Border: 1pt #30363D

Focused:
  Background: #0D1117
  Border: 2pt #1F6FEB
  Shadow: 0 0 0 3pt #0C2D6B (outer glow)

Error:
  Border: 2pt #F85149
  Shadow: 0 0 0 3pt #521716
```

### 3. 卡片 Card

```swift
Background: #161B22
Border: 1pt #30363D
Corner Radius: 12pt
Shadow: shadow-md
Highlight: #21262D (on tap)
```

### 4. 列表 List

```swift
Cell Background: #161B22
Selected Background: #21262D
Separator: 1pt #21262D (left inset: 16pt)
Section Header: #8B949E, 13pt Semibold
```

### 5. 导航栏 Navigation Bar

```swift
Standard Appearance:
  Background: #161B22 (translucent)
  Title Text: #F0F6FC, 17pt Semibold
  Tint Color: #58A6FF

Scroll Edge Appearance:
  Background: #0D1117 (transparent)
  Large Title: #F0F6FC, 34pt Bold
```

### 6. Tab Bar

```swift
Background: #161B22 (translucent)
Selected Item: #F0F6FC
Unselected Item: #6E7681
Item Font: 10pt Regular
Tint Color: #58A6FF
```

### 7. 标签 Labels / Badges

| 类型 | 背景色 | 文字色 | 边框 |
|------|--------|--------|------|
| Default | `#21262D` | `#F0F6FC` | `#30363D` |
| Green | `#238636` (20% opacity) | `#3FB950` | `#238636` |
| Blue | `#1F6FEB` (20% opacity) | `#58A6FF` | `#1F6FEB` |
| Red | `#DA3633` (20% opacity) | `#F85149` | `#DA3633` |
| Purple | `#8957E5` (20% opacity) | `#A371F7` | `#8957E5` |
| Yellow | `#9E6A03` (20% opacity) | `#E3B341` | `#9E6A03` |

---

## 💻 代码语法高亮配色

适配 GitHub 暗色主题的代码高亮配色：

| Syntax Element | Color | Hex |
|----------------|-------|-----|
| Plain Text | 浅白 | `#C9D1D9` |
| Keyword | 紫色 | `#FF7B72` |
| String | 青色 | `#A5D6FF` |
| Number | 蓝色 | `#79C0FF` |
| Comment | 灰色 | `#8B949E` |
| Function | 紫色 | `#D2A8FF` |
| Variable | 橙色 | `#FFA657` |
| Operator | 浅蓝 | `#79C0FF` |
| Tag | 绿色 | `#7EE787` |
| Attribute | 紫色 | `#FFA198` |

---

## 📱 状态栏与系统控件适配

### 状态栏 Status Bar

```swift
Style: .lightContent
Background: 透明 (自动继承导航栏)
```

### 活动指示器 Activity Indicator

```swift
Style: .medium (浅色)
Color: #8B949E
```

### 开关 Switch

```swift
On Tint: #238636
Thumb: #FFFFFF
Background (Off): #30363D
```

### 滑块 Slider

```swift
Minimum Track Tint: #58A6FF
Maximum Track Tint: #30363D
Thumb Tint: #FFFFFF
```

---

## 🔄 亮/暗主题切换规范

### 自动切换支持

```swift
// 使用 iOS 系统的自动深色模式
overrideUserInterfaceStyle = .unspecified

// 手动切换时
UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve) {
    self.view.overrideUserInterfaceStyle = .dark // 或 .light
}
```

### 切换动画

- **时长**: 300ms
- **动画曲线**: EaseInOut
- **过渡方式**: CrossDissolve (交叉淡入淡出)

---

## ✅ 可访问性检查 Accessibility

### 对比度验证

| 元素 | 对比度 | 等级 |
|------|--------|------|
| 主要文字 | 13.5:1 | ✅ AAA |
| 次要文字 | 5.9:1 | ✅ AA |
| 辅助文字 | 4.2:1 | ✅ AA |
| 按钮文字 | 14.0:1 | ✅ AAA |
| 链接文字 | 6.4:1 | ✅ AA |
| 成功文字 | 7.3:1 | ✅ AA |

### 降低透明度支持

当用户开启"降低透明度"时：
- 半透明背景 → 不透明背景
- 毛玻璃效果 → 纯色背景
- 透明度从 80% → 100%

### 增强对比度支持

当用户开启"增强对比度"时：
- 边框颜色加深 20%
- 文字颜色饱和度增加
- 按钮边框更粗 (从 1pt 到 1.5pt)

---

## 🎨 主题切换 Swift 实现参考

```swift
// GitHubTheme.swift

import UIKit

enum GitHubTheme {
    static func apply() {
        // 导航栏
        UINavigationBar.appearance().tintColor = .init(hex: "#58A6FF")
        UINavigationBar.appearance().barTintColor = .init(hex: "#161B22")
        
        // 标题文字属性
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(hex: "#F0F6FC"),
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        UINavigationBar.appearance().titleTextAttributes = titleAttributes
        
        // Tab Bar
        UITabBar.appearance().tintColor = .init(hex: "#58A6FF")
        UITabBar.appearance().unselectedItemTintColor = .init(hex: "#6E7681")
        
        // TableView
        UITableView.appearance().backgroundColor = .init(hex: "#0D1117")
        UITableViewCell.appearance().backgroundColor = .init(hex: "#161B22")
        
        // UIButton
        UIButton.appearance(whenContainedInInstancesOf: [PrimaryButton.self])
            .tintColor = .init(hex: "#238636")
    }
}

// MARK: - Color Extension
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
```

---

## 📋 暗色主题检查清单

发布前验证清单：

- [ ] 所有页面背景色正确 (`#0D1117`)
- [ ] 卡片/弹窗背景为 `#161B22`
- [ ] 文字对比度达标 (≥4.5:1)
- [ ] 按钮状态样式完整 (normal/highlighted/disabled)
- [ ] 输入框聚焦边框为蓝色 (`#1F6FEB`)
- [ ] 分割线颜色正确 (`#21262D`)
- [ ] 图标颜色匹配文字层级
- [ ] 状态栏样式为 `.lightContent`
- [ ] 支持动态类型缩放
- [ ] 亮/暗切换动画流畅

---

**文档结束**