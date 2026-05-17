# 📱 GitHub iOS App 侧载安装指南

> 无需开发者账号！无需越狱！

---

## 🎯 推荐安装方式

### 方式1：Sideloadly（最简单）⭐️

**优点：** 免费、无需开发者账号、支持WiFi安装

#### 安装步骤：

1. **下载 Sideloadly**
   - 官网：https://sideloadly.io/
   - 支持 Windows 和 macOS

2. **准备 IPA 文件**
   - 使用 `scripts/build_macOS.sh` 脚本构建
   - 或使用 Xcode 归档导出

3. **安装步骤**
   ```
   1. 打开 Sideloadly
   2. 连接你的 iPhone/iPad 到电脑
   3. 将 IPA 文件拖放到 Sideloadly
   4. 输入你的 Apple ID
   5. 点击 "Start" 开始安装
   6. 在 iPhone 上信任开发者：
      设置 → 通用 → VPN与设备管理 → 信任你的Apple ID
   7. 打开 APP！
   ```

---

### 方式2：AltStore

**优点：** 无线安装、7天自动续签

**下载地址：** https://altstore.io/

#### 安装步骤：

1. 电脑安装 AltServer
2. 手机和电脑在同一WiFi
3. AltServer → Install AltStore → 选择你的设备
4. 安装 AltStore 到手机
5. 手机上打开 AltStore
6. 点击 "+" → 选择 IPA 文件
7. 等待安装完成

---

### 方式3：Xcode 直接安装（开发者）

适合有 Xcode 的开发者：

1. 打开 Xcode
2. Window → Devices and Simulators
3. 选择你的 iOS 设备
4. 点击 "Installed Apps" 下的 "+"
5. 选择生成的 IPA 文件
6. 等待安装完成

---

## 🛠️ 构建 IPA 步骤（macOS）

### 第一步：克隆代码

```bash
git clone https://github.com/5shunchen/github-app.git
cd github-app
```

### 第二步：运行一键构建脚本

```bash
chmod +x scripts/build_macOS.sh
./scripts/build_macOS.sh development
```

构建完成后，IPA 文件位置：
```
IPA/GitHubApp-v1.0.0-Dev.ipa
```

---

## ⚙️ Xcode 手动构建（推荐）

### 1. 打开项目

```bash
open GitHubApp.xcodeproj
```

### 2. 配置签名（重要！）

```
1. 点击项目根节点 GitHubApp
2. 选择 TARGETS → GitHubApp
3. 选择 "Signing & Capabilities"
4. 勾选 "Automatically manage signing"
5. Team 选择你的 Apple ID / 开发团队
6. Bundle Identifier 修改为你自己的（例如 com.yourname.githubapp）
```

### 3. 选择设备

```
Xcode 顶部 → 选择你的 iPhone/iPad 设备
```

### 4. 运行！

```
点击 Run 按钮（▶️）
或按快捷键 Cmd + R
```

---

## 🔧 常见问题解决

### ❌ "无法验证开发者"

**解决方法：**
```
设置 → 通用 → VPN与设备管理 → 找到开发者 → 点击信任
```

### ❌ "签名失败"

**解决方法：**
```
1. 确认登录了 Apple ID
2. Xcode → Settings → Accounts
3. Bundle ID 必须唯一，不能和别人重复
4. 项目 Bundle ID 修改为自己的（例如 com.你的名字.githubapp）
```

### ❌ "设备未添加到账户"

**解决方法：**
```
Xcode 会提示自动添加设备，点击 "Register Device" 即可
```

### ❌ "应用闪退"

**解决方法：**
```
1. 检查设备是否在支持列表（iOS 16.0+）
2. 重新签名安装
3. 检查是否信任了开发者
```

---

## 📋 系统要求

- **iOS 版本：** 16.0 或更高
- **Xcode 版本：** 14.0 或更高
- **支持设备：** iPhone 8+, iPad (第5代+), iPod Touch (第7代)

---

## 🔄 7天后续签（免费Apple ID）

免费开发者账号签名有效期7天，到期后：

**方式1：重新用 Sideloadly 安装**
- 连接设备 → 重新拖放 IPA → Start

**方式2：AltStore 自动续签**
- AltServer 在后台运行时会自动续签

---

## 🎉 配置 GitHub OAuth（可选）

安装完成后，配置自己的 GitHub OAuth 才能登录：

1. 打开 GitHub → Settings → Developer settings → OAuth Apps
2. 点击 "New OAuth App"
3. 填写信息：
   - Application name: GitHub iOS App
   - Homepage URL: https://github.com
   - Authorization callback URL: githubapp://callback
4. 生成 Client ID 和 Client Secret
5. 在 App 代码中填入 `AppConfig.swift`

---

## 📞 技术支持

如遇问题：
1. 检查 iOS 版本 ≥ 16.0
2. 确认 Xcode 版本 ≥ 14.0
3. Bundle ID 必须唯一
4. 设备已添加到开发者账户

---

**享受你的 GitHub iOS App！** 🚀📱
