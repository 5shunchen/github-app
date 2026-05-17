# GitHub iOS App - UI/UX 设计规范交付

> **Project:** GitHub iOS App Redesign  
> **Design Phase:** UI/UX Specifications  
> **Delivered Date:** 2026-05-17  
> **Delivered To:** Product Management & Development Team

---

## 📦 交付内容清单

| # | 文档名称 | 文件 | 状态 |
|---|----------|------|------|
| 1 | 整体视觉与交互规范 | `GitHub-iOS-Design-System.md` | ✅ 完成 |
| 2 | 暗色主题设计规范 | `GitHub-Dark-Theme-Spec.md` | ✅ 完成 |
| 3 | UI 组件设计规范 | `GitHub-UI-Components-Spec.md` | ✅ 完成 |
| 4 | 颜色定义 JSON | `GitHub-Color-Definitions.json` | ✅ 完成 |

---

## 🎨 设计概览

### 核心设计理念

1. **开发者优先** - 代码友好，聚焦内容，减少视觉噪音
2. **平台原生** - 遵循 iOS HIG，使用系统控件，体验流畅
3. **GitHub 一致** - 与 GitHub Web 端 Primer 设计系统 1:1 对齐
4. **可访问性** - WCAG AA 标准，支持动态类型、VoiceOver

### 视觉特征

| 特征 | 描述 |
|------|------|
| **主题** | GitHub Dark Default（默认暗色主题） |
| **主色** | GitHub 绿 `#238636` |
| **背景层级** | 3 层深色背景体系，创造深度感 |
| **字体** | SF Pro，语义化字体层级 |
| **图标** | SF Symbols 5+，与 GitHub 风格对齐 |

---

## 📋 设计系统核心内容

### 1. 色彩系统 (完整 50+ 色值)

- ✅ 主色调 (绿、蓝、紫、红、黄、橙)
- ✅ 背景色层级 (canvas / default / subtle / inset)
- ✅ 文字层级 (primary / secondary / tertiary / link)
- ✅ 边框与分割线
- ✅ 状态色 (成功/警告/错误/信息)
- ✅ 编程语言颜色 (18+ 常用语言)

### 2. 排版系统

| 字号 | 字重 | 用途 |
|------|------|------|
| 34pt Bold | 大标题 | 页面大标题 |
| 28pt Bold | 一级标题 | 页面标题 |
| 17pt Semibold | 三级标题 | 栏目标题 |
| 17pt Regular | 正文 | 主要内容 |
| 15pt / 13pt | 次级文字 | 描述、辅助文字 |
| 12pt / 11pt | 标签元数据 | 标签、计数 |

### 3. 布局系统

- ✅ 4pt 基础网格
- ✅ 标准间距 Token (4/8/12/16/20/24/32pt)
- ✅ 圆角规范 (4/6/8/12pt + 胶囊)
- ✅ 页面边距 16pt
- ✅ 安全区自动适配

### 4. 动效规范

- ✅ 标准动画时长 250ms
- ✅ EaseInOut 缓动曲线
- ✅ 弹簧动画参数
- ✅ 页面转场动画 300ms

---

## 🌙 暗色主题完整规范

### 三层背景体系

```
Canvas (最底层):   #0D1117  ← 页面背景
  └─ Default:      #161B22  ← 卡片、导航栏、弹窗
      └─ Subtle:   #21262D  ← 输入框、按钮、选中行
```

### 文字对比度保证

| 层级 | 对比度 | WCAG 等级 |
|------|--------|-----------|
| 主要文字 | 13.5:1 | ✅ AAA |
| 次要文字 | 5.9:1 | ✅ AA |
| 辅助文字 | 4.2:1 | ✅ AA |
| 链接文字 | 6.4:1 | ✅ AA |

### 主题特性

- ✅ 纯黑背景护眼，适合长时间使用
- ✅ 代码语法高亮配色优化
- ✅ 支持系统自动深色/浅色切换
- ✅ 交叉淡入淡出切换动画
- ✅ 支持"降低透明度"和"增强对比度"

---

## 🧩 UI 组件库 (10+ 组件类型)

### 按钮组件

| 类型 | 规格 | 状态 |
|------|------|------|
| Primary | 48pt 高度 | Normal / Highlighted / Disabled / Loading |
| Secondary | 48pt 高度 | Normal / Highlighted / Disabled |
| Danger | 48pt 高度 | Normal / Highlighted |
| Icon | 32pt / 24pt | Normal / Highlighted / Selected |

### 输入组件

- ✅ Text Field (48pt, 聚焦/错误状态)
- ✅ Search Field (36pt, 胶囊造型)
- ✅ Switch (标准开关样式)

### 导航组件

- ✅ Navigation Bar (标准 + 大标题模式)
- ✅ Tab Bar (5 个标准 Tab)
- ✅ Segmented Control (32pt 高度)

### 列表组件

- ✅ Standard Cell (56pt / 72pt 带副标题)
- ✅ Repository Cell (88pt, 完整仓库信息)
- ✅ Issue/PR Cell (72pt / 92pt, 状态图标)

### 其他组件

- ✅ Cards (基础卡片 / 置顶仓库卡片)
- ✅ Badges (计数标签 / 状态标签)
- ✅ Avatars (5 种尺寸 / 头像栈)
- ✅ Bottom Sheet (分享/操作菜单)
- ✅ Progress / Activity Indicator
- ✅ Toast / Empty State

---

## 🔧 开发实现指南

### Swift 颜色定义示例

```swift
extension UIColor {
    static let gh = GitHubColors.self
}

enum GitHubColors {
    static let canvas = UIColor(hex: "#0D1117")
    static let `default` = UIColor(hex: "#161B22")
    static let subtle = UIColor(hex: "#21262D")
    
    static let textPrimary = UIColor(hex: "#F0F6FC")
    static let textSecondary = UIColor(hex: "#8B949E")
    static let link = UIColor(hex: "#58A6FF")
    
    static let borderDefault = UIColor(hex: "#30363D")
    static let accentGreen = UIColor(hex: "#238636")
    static let accentRed = UIColor(hex: "#F85149")
}
```

### 组件实现优先级

| 优先级 | 组件 | 建议里程碑 |
|--------|------|-----------|
| P0 | 颜色系统、字体系统 | M1 - Week 1 |
| P0 | 按钮、输入框 | M1 - Week 1 |
| P0 | 导航栏、Tab Bar | M1 - Week 2 |
| P1 | 列表组件 (仓库/Issue/PR) | M1 - Week 2 |
| P1 | 卡片、标签 | M2 - Week 3 |
| P2 | 头像、底部弹窗 | M2 - Week 4 |

---

## ✅ 验收标准

### 设计完整性检查

- [x] 所有组件状态定义完整
- [x] 深色主题配色完整
- [x] 可访问性对比度达标
- [x] 支持动态类型适配
- [x] iOS HIG 规范对齐
- [x] GitHub Primer 系统对齐

### 开发实现验证清单

- [ ] 颜色 Token 1:1 实现
- [ ] 组件圆角使用 `.continuous` 曲线
- [ ] 按钮可点击区域 ≥ 44pt x 44pt
- [ ] 所有状态样式正确实现
- [ ] VoiceOver Label 完整
- [ ] 动态类型自动缩放
- [ ] 安全区适配正确

---

## 📚 参考资源

1. **GitHub Primer Design System** - https://primer.style/
2. **Apple Human Interface Guidelines** - https://developer.apple.com/design/human-interface-guidelines/
3. **SF Pro Font** - https://developer.apple.com/fonts/
4. **SF Symbols 5** - https://developer.apple.com/sf-symbols/

---

## 📮 后续支持

设计团队将提供：

1. 设计走查 (Design Walkthrough) - 组件开发完成后
2. 页面级详细设计稿 - 按功能模块迭代交付
3. 交互原型 - 关键流程动画演示
4. 技术答疑 - 实现过程中的设计问题支持

---

**设计交付完成 ✅**

_PM 确认签字: _______________  日期: _______________