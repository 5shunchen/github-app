# GitHub iOS App - 设计系统规范

> **Version:** 1.0.0  
> **Last Updated:** 2026-05-17  
> **Platform:** iOS 17+  
> **Designer:** UI/UX Design Team

---

## 📋 目录

1. [整体视觉规范](#整体视觉规范)
2. [交互规范](#交互规范)
3. [暗色主题设计](#暗色主题设计)
4. [UI组件规范](#ui组件规范)
5. [布局系统](#布局系统)

---

## 🎨 整体视觉规范

### 1.1 设计理念

GitHub iOS App 遵循 GitHub 官方设计语言，强调：
- **开发者优先**：代码友好、功能直观
- **简洁高效**：减少视觉噪音，聚焦内容
- **一致性**：与 GitHub Web 端体验保持统一
- **可访问性**：支持动态类型、高对比度

### 1.2 品牌色彩系统

#### 主色 Primary

| 色值 | 用途 | 十六进制 |
|------|------|----------|
| GitHub 绿 | 主按钮、选中状态、链接 | `#238636` |
| GitHub 蓝 | 信息提示、链接悬停 | `#58A6FF` |
| GitHub 紫 | 功能强调、标签 | `#8957E5` |

#### 辅助色 Accent

| 色值 | 用途 | 十六进制 |
|------|------|----------|
| 橙色 | 警告、待处理 | `#D29922` |
| 红色 | 错误、删除 | `#DA3633` |
| 青色 | 成功、通过 | `#3FB950` |

#### 中性色 Neutral

| 层级 | 用途 | 十六进制 |
|------|------|----------|
| N0 | 纯白、背景 | `#FFFFFF` |
| N10 | 边框、分割线 | `#E6E8EA` |
| N20 | 次要边框 | `#D1D5DA` |
| N30 | 禁用状态 | `#AFB4BA` |
| N50 | 次要文字 | `#656D76` |
| N70 | 主要文字 | `#24292F` |
| N100 | 纯黑 | `#000000` |

---

## 🔤 字体系统 Typography

采用 **SF Pro** 系统字体，配合动态类型支持。

| 字号 | 字重 | 行高 | 用途 |
|------|------|------|------|
| 34pt | Bold | 41pt | 大标题 (Large Title) |
| 28pt | Bold | 34pt | 一级标题 (Title 1) |
| 22pt | Semibold | 28pt | 二级标题 (Title 2) |
| 17pt | Semibold | 22pt | 三级标题 (Title 3) |
| 17pt | Regular | 22pt | 正文 (Body) |
| 15pt | Regular | 20pt | 次级正文 (Callout) |
| 13pt | Regular | 18pt | 脚注 (Footnote) |
| 12pt | Regular | 16pt | 说明文字 (Caption 1) |
| 11pt | Regular | 13pt | 标签文字 (Caption 2) |

### 字体字重规范

- **Bold (700)**: 页面标题、重要数据
- **Semibold (600)**: 栏目标题、按钮文字
- **Medium (500)**: 列表标题、次要强调
- **Regular (400)**: 正文、描述文字

---

## 📐 布局系统 Layout

### 间距规范 Spacing

采用 4px 基础网格系统：

| Token | 像素值 | 用途 |
|-------|--------|------|
| `spacing-1` | 4px | 微间距、图标内边距 |
| `spacing-2` | 8px | 小组件间距、内边距 |
| `spacing-3` | 12px | 卡片内边距 |
| `spacing-4` | 16px | 标准间距、页面边距 |
| `spacing-5` | 20px | 元素间距 |
| `spacing-6` | 24px | 大间距、区块间距 |
| `spacing-8` | 32px | 页面顶部/底部间距 |
| `spacing-10` | 40px | 超大间距 |

### 页面边距

- **左右边距**: 16px (`spacing-4`)
- **上下边距**: 20px (`spacing-5`)
- **安全区**: 自动适配 Notch/Dynamic Island

### 圆角规范 Border Radius

| Token | 像素值 | 用途 |
|-------|--------|------|
| `radius-1` | 4px | 小型标签、徽章 |
| `radius-2` | 6px | 按钮、输入框 |
| `radius-3` | 8px | 卡片、弹窗 |
| `radius-4` | 12px | 大卡片、底部弹窗 |
| `radius-full` | 9999px | 头像、胶囊按钮 |

---

## 👆 交互规范 Interaction

### 点击状态

| 状态 | 视觉反馈 |
|------|----------|
| Normal | 默认样式 |
| Highlighted | 不透明度 70% |
| Disabled | 不透明度 50%，不可点击 |
| Selected | 主色背景 + 白色图标/文字 |

### 手势规范

- **点击 (Tap)**: 按钮、链接、卡片选中
- **长按 (Long Press)**: 预览、快捷操作
- **滑动 (Swipe)**: 列表删除、返回
- **捏合 (Pinch)**: 图片缩放
- **拖动 (Drag)**: 排序、移动

### 动画规范 Animation

- **标准时长**: 250ms
- **缓动曲线**: `EaseInOut` (0.42, 0, 0.58, 1)
- **弹簧动画**: 阻尼 0.7，初始速度 0.5
- **页面转场**: 300ms，左侧推入/右侧划出

---

## 🌙 暗色主题设计 Dark Theme

### 暗色主题色彩系统

#### 背景色 Background

| 层级 | 用途 | 十六进制 |
|------|------|----------|
| `bg-primary` | 主背景 | `#0D1117` |
| `bg-secondary` | 次级背景、卡片 | `#161B22` |
| `bg-tertiary` | 输入框、按钮背景 | `#21262D` |
| `bg-overlay` | 弹窗遮罩 | `#000000` (80% opacity) |

#### 文字颜色 Text

| 层级 | 用途 | 十六进制 |
|------|------|----------|
| `text-primary` | 主要文字 | `#F0F6FC` |
| `text-secondary` | 次要文字 | `#8B949E` |
| `text-tertiary` | 辅助文字 | `#6E7681` |
| `text-link` | 链接文字 | `#58A6FF` |
| `text-danger` | 错误文字 | `#F85149` |
| `text-success` | 成功文字 | `#3FB950` |
| `text-warning` | 警告文字 | `#E3B341`` |

#### 边框与分割线 Border

| 层级 | 用途 | 十六进制 |
|------|------|----------|
| `border-primary` | 主要边框 | `#30363D` |
| `border-secondary` | 次要边框 | `#21262D` |
| `border-tertiary` | 分割线 | `#3D444D` |

#### 主色在暗色主题下的调整

| 原色 | 暗色主题值 | 用途 |
|------|------------|------|
| GitHub 绿 | `#238636` | 主按钮、选中状态 |
| GitHub 绿 (悬停) | `#2EA043` | 按钮悬停 |
| GitHub 蓝 | `#58A6FF` | 链接、信息 |
| GitHub 紫 | `#A371F7` | 强调、标签 |

### 暗色主题设计原则

1. **降低对比度**：避免纯白文字在纯黑背景上的视觉疲劳
2. **提升蓝色**：蓝色在暗色背景下更清晰，用于链接和强调
3. **减少饱和**：主色饱和度略微降低，避免刺眼
4. **分层视觉**：通过背景色深浅创建视觉层级

---

## 🧩 UI组件规范 Components

### 1. 按钮 Buttons

#### 主要按钮 Primary Button

```swift
// 样式规范
背景色: #238636 (normal), #2EA043 (highlighted)
文字色: #FFFFFF
高度: 48pt
圆角: 6pt
字重: Semibold 600
内边距: 水平 16pt, 垂直 12pt
```

#### 次要按钮 Secondary Button

```swift
背景色: #21262D
边框: 1pt #30363D
文字色: #F0F6FC
高度: 48pt
圆角: 6pt
```

#### 危险按钮 Danger Button

```swift
背景色: #DA3633
文字色: #FFFFFF
高度: 48pt
圆角: 6pt
```

#### 图标按钮 Icon Button

```swift
尺寸: 32pt x 32pt
图标: 20pt x 20pt
圆角: 6pt
背景: 透明 (normal), #21262D (highlighted)
```

### 2. 输入框 Text Field

```swift
高度: 48pt
圆角: 6pt
边框: 1pt #30363D
背景: #0D1117
文字: #F0F6FC
占位符: #6E7681
内边距: 水平 12pt
聚焦状态: 边框 2pt #58A6FF
```

### 3. 列表项 List Item

```swift
高度: 56pt (标准), 72pt (带副标题)
分割线: 1pt #21262D，左侧缩进 16pt
左右边距: 16pt
图标尺寸: 20pt
右侧箭头: chevron.right, #6E7681
选中背景: #21262D
```

### 4. 卡片 Card

```swift
背景: #161B22
圆角: 12pt
边框: 1pt #30363D
内边距: 16pt
阴影: 无 (暗色模式使用边框区分)
```

### 5. 标签 Badge

```swift
高度: 20pt
圆角: 10pt (capsule)
内边距: 水平 8pt, 垂直 2pt
字体: 11pt Semibold
颜色种类: default / green / blue / red / purple
```

### 6. 导航栏 Navigation Bar

```swift
背景: #161B22 (半透明模糊效果)
标题: 17pt Semibold, #F0F6FC
大标题: 34pt Bold, #F0F6FC ( prefersLargeTitles )
返回按钮: chevron.left 图标 + "Back"
右侧按钮: 图标按钮 24pt
```

### 7. Tab Bar

```swift
高度: 49pt (标准) + 安全区
背景: #161B22 (半透明)
选中图标: #F0F6FC
未选中图标: #6E7681
文字: 10pt Regular
```

### 8. 分段控制 Segmented Control

```swift
高度: 32pt
背景: #21262D
选中项背景: #30363D
文字: 13pt Semibold
圆角: 6pt
选项间距: 2pt
```

---

## 📱 页面模板规范

### 仓库详情页

```
┌─────────────────────────────────────┐
│  <  owner/repo              ⋯  ↗    │  Navigation Bar
├─────────────────────────────────────┤
│  📦 Repo Name                       │
│  Description text goes here...      │  Header Info
│  🌟 12.5k  🍴 2.3k                  │
├─────────────────────────────────────┤
│  ┌─────────────────────────────────┐│
│  │ 🟢 Code  │ Issues  │ PRs  │ ⋯   ││  Segmented Control
│  └─────────────────────────────────┘│
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 📁 README.md                   │ │
│  └───────────────────────────────┘ │  File List
│  ┌───────────────────────────────┐ │
│  │ 📁 src/                        │ │
│  └───────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

### 个人主页

```
┌─────────────────────────────────────┐
│  <  Username                ⋯  ↗    │
├─────────────────────────────────────┤
│  [Avatar]  Name                      │
│            @username                 │  Profile Header
│            📍 Location  🔗 Website  │
│            📝 Bio description...    │
├─────────────────────────────────────┤
│  ┌─────────────────────────────────┐│
│  │ Overview  │ Repos  │ Stars  │ ⋯ ││  Segmented Control
│  └─────────────────────────────────┘│
├─────────────────────────────────────┤
│  Pinned Repositories                 │
│  [Card] [Card] [Card]                │  Pinned Grid
└─────────────────────────────────────┘
```

---

## ✅ 可访问性规范 Accessibility

### 颜色对比度

- 正文文字: **≥ 4.5:1** (WCAG AA)
- 大文字: **≥ 3:1** (WCAG AA)
- 图标组件: **≥ 3:1**

### 动态类型支持

所有文字元素支持 iOS 动态类型功能：
- 最大支持到 `.accessibilityExtraExtraExtraLarge`
- 布局自动适应字体大小变化

### VoiceOver

- 所有交互元素必须有 `accessibilityLabel`
- 复杂元素使用 `accessibilityElements`
- 状态变化使用 `UIAccessibility.post` 通知

---

## 🚀 实现注意事项

### 开发规范

1. 使用 **SF Symbols** 图标库，版本 5+
2. 所有颜色使用 **Asset Catalog** 定义，支持暗黑模式自动切换
3. 优先使用 `UIConfigurationColorTransformer` 处理状态颜色
4. 采用 Auto Layout，配合 Size Classes 适配不同设备

### 性能优化

1. 列表复用 (`UITableViewCell` / `UICollectionViewCell`)
2. 图片异步加载 + 缓存
3. 避免图层混合 (layer.blendMode)
4. 圆角使用 `cornerCurve = .continuous`

---

## 📚 参考资源

- [GitHub Primer Design System](https://primer.style/)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SF Pro Font](https://developer.apple.com/fonts/)
- [SF Symbols](https://developer.apple.com/sf-symbols/)

---

**文档结束**
