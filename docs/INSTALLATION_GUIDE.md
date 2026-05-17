# 📲 GitHub iOS App Installation Guide

## 📋 Table of Contents
1. [Development Setup](#1-development-setup)
2. [Building the IPA](#2-building-the-ipa)
3. [Installation Methods](#3-installation-methods)
4. [Troubleshooting](#4-troubleshooting)
5. [Distribution Options](#5-distribution-options)

---

## 1. Development Setup

### Prerequisites

| Requirement | Version |
|--------------|---------|
| macOS | Ventura 13.0+ |
| Xcode | 15.0+ |
| iOS | 16.0+ |
| Apple Developer Account | Required |

### Step 1: Configure Xcode

```bash
# Install Xcode command line tools
xcode-select --install

# Accept Xcode license
sudo xcodebuild -license accept
```

### Step 2: GitHub OAuth Setup

1. Go to [GitHub Developer Settings](https://github.com/settings/developers)
2. Create a new OAuth App:
   - **Application name**: GitHub iOS App
   - **Homepage URL**: https://github.com
   - **Authorization callback URL**: `githubapp://oauth/callback`
3. Copy your **Client ID** and **Client Secret**

### Step 3: Configure App Credentials

Edit `GitHubApp/Core/Config/AppConfig.swift`:

```swift
enum AppConfig {
    enum OAuth {
        static let clientID = "YOUR_CLIENT_ID"      // ← Replace
        static let clientSecret = "YOUR_CLIENT_SECRET"  // ← Replace
        static let redirectURI = "githubapp://oauth/callback"
        static let scope = "repo,user,notifications"
    }
}
```

### Step 4: Configure Code Signing

1. Open `GitHubApp.xcodeproj` in Xcode
2. Select the **GitHubApp** target
3. Go to **Signing & Capabilities** tab
4. Select your **Team** from the dropdown
5. Set **Bundle Identifier** (e.g., `com.yourcompany.GitHubApp`)
6. Ensure "Automatically manage signing" is checked

---

## 2. Building the IPA

### Option A: Using Xcode (Manual Build

1. **Select Destination**:
   - Choose a simulator: `Product → Destination → Any iOS Device (arm64)`
   
2. **Archive**:
   - `Product → Archive` (Cmd+Shift+B)
   - Wait for build to complete

3. **Export**:
   - In the Organizer window, select your archive
   - Click "Distribute App"
   - Choose your distribution method:
     - **Development**: Test devices
     - **App Store Connect**: App Store / TestFlight
     - **Enterprise**: In-house distribution
   - Follow the wizard to export the IPA

### Option B: Using Build Script

```bash
cd GitHubApp

# Make script executable
chmod +x scripts/build.sh

# Development build
./scripts/build.sh dev

# Release build
./scripts/build.sh prod

# Enterprise build
./scripts/build.sh enterprise
```

**Output Location**: `build/GitHubApp-*.ipa`

### Option C: Using Fastlane

```bash
# Install fastlane
gem install bundler
bundle install

# Set environment variables
export DEVELOPMENT_TEAM="YOUR_TEAM_ID"
export APPLE_ID="your@email.com"

# Build
bundle exec fastlane build_dev    # Development
bundle exec fastlane build_release  # App Store
```

---

## 3. Installation Methods

### 📱 Method 1: Xcode Device Installation

**For Development Provisioned Devices:

1. Connect your iOS device via USB
2. Open Xcode → Window → Devices and Simulators
3. Select your device under "Devices"
4. Under "Installed Apps", click **+**
5. Select `Select your `GitHubApp.ipa` file
6. Wait for installation to complete

### ✈️ Method 2: TestFlight (Recommended for Beta)

1. **Upload to App Store Connect**:
   - Archive in Xcode → "Distribute App" → "App Store Connect"
   - Or use `fastlane deliver`

2. **Create TestFlight Group**:
   - Go to [App Store Connect](https://appstoreconnect.apple.com)
   - Select your app → TestFlight
   - Create an internal or external testing group

3. **Add Testers**:
   - Add testers by email
   - Or create a public link
   - Up to 10,000 external testers

4. **Install via TestFlight App:
   - Testers receive email invitation
   - Download TestFlight from App Store
   - Redeem invitation code
   - Install app directly on device

### 🏢 Method 3: Enterprise In-House Distribution

**For Enterprise Developer Accounts Only:**

1. **Build with Enterprise Certificate
2. **Host IPA on HTTPS Server**
3. **Create Installation Manifest (`manifest.plist`):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>items</key>
    <array>
        <dict>
            <key>assets</key>
            <array>
                <dict>
                    <key>kind</key><string>software-package</string>
                    <key>url</key><string>https://your-server.com/GitHubApp.ipa</string>
                </dict>
                <dict>
                    <key>kind</key><string>display-image</string>
                    <key>url</key><string>https://your-server.com/icon.57x57.png</string>
                </dict>
                <dict>
                    <key>kind</key><string>full-size-image</string>
                    <key>url</key><string>https://your-server.com/icon.512x512.png</string>
                </dict>
            </array>
            <key>metadata</key>
            <dict>
                <key>bundle-identifier</key><string>com.githubapp.ios</string>
                <key>bundle-version</key><string>1.0</string>
                <key>kind</key><string>software</string>
                <key>title</key><string>GitHub App</string>
                <key>subtitle</key><string>GitHub Client</string>
            </dict>
        </dict>
    </array>
</dict>
</plist>
```

4. **Create Installation Web Page**:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Install GitHub App</title>
</head>
<body>
    <h1>GitHub iOS App</h1>
    <a href="itms-services://?action=download-manifest&url=https://your-server.com/manifest.plist">
        Tap here to install
    </a>
</body>
</html>
```

5. **Distribute Link to Employees:
   - Send installation webpage via email or internal portal
   - Users tap link on their device Safari
   - "Tap "Install" when prompted

### 🔧 Method 4: Side Loading (Development)

**Tools for development without full developer account:

| Tool | URL | Notes |
|------|-----|-------|
| **AltStore** | https://altstore.io | Free, Wi-Fi refresh |
| **Sideloadly** | https://sideloadly.io | Free, GUI |
| **iOS App Signer** | https://dantheman827.github.io/ios-app-signer/ | Open source |

**Using AltStore**:
1. Install AltServer on your Mac/PC
2. Connect iOS device via same Wi-Fi
3. Install AltStore to device
4. Use AltStore to sideload IPA

---

## 4. Troubleshooting

### Common Installation Issues

#### ❌ "Unable to Install"

**Cause**: App is provisioning issues

**Solutions**:
1. Verify device UDID is in provisioning profile
2. Check certificate is not expired
3. Ensure device iOS version ≥ deployment target
4. Reboot device and try again
5. Check device trust developer/app in Settings → General → VPN & Device Management

#### ❌ "Untrusted Developer"

**Fix**:
1. After installation fails with "Untrusted Enterprise Developer"
2. Go to **Settings → General → VPN & Device Management**
3. Tap your developer account
4. Tap "Trust [Developer Name]"
5. Confirm trust dialog

#### ❌ App Crashes on Launch

**Debug Steps**:
1. Check device console logs: Xcode → Devices → Open Console
2. Verify all dependencies are embedded
3. Validate code signing: `codesign -d --verbose /path/to/app`
4. Look for crashes early lifecycle issues

#### ❌ Build Failures

**Clean and Rebuild**:
```bash
# Clean build
Cmd+Shift+K in Xcode

# Delete derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Reset packages:
rm -rf ~/Library/Caches/org.carthage
```

### Code Signing Verification

```bash
# Check certificate identity list
security find-identity -v -p codesigning

# Verify app IPA
unzip -q App.ipa
codesign -d --verbose Payload/*.app

# Check provisioning profile
security cms -D -i Payload/*.app/embedded.mobileprovision
```

### Useful Commands

```bash
# View device logs
idevicedebug #############4444

# Install via libimobiledevice
brew install libimobiledevice
ideviceinstaller -i GitHubApp.ipa
```

---

## 5. Distribution Options Comparison

| Method | Devices | Review | Max UDID Required? | Best For |
|--------|---------|--------|---------------------|----------|
| **TestFlight Internal | 10,000 | ✅ Yes | No | Beta testing |
| **App Store** | Unlimited | ✅ Yes | No | Public release |
| **Development | 100 | No | Yes | Development team |
| **Enterprise** | Unlimited | No | No | Company employees |
| **Ad-Hoc** | 100 | No | Yes | Small team testing |

---

## 📱 Required Capabilities

The app requires these capabilities:

| Capability | Purpose |
|------------|---------|
| Keychain Sharing | Secure token storage |
| Internet Access | GitHub API communication |
| URL Schemes | OAuth callback handler |

---

## 🔐 Security Notes

⚠️ **Important**:
- Never distribute development certificates or private keys to repository
- Use environment variables for secrets
- Regularly rotate signing certificates annually
- Revoke compromised credentials immediately
- IPA files can be re-signed distribution methods revoke distribution

---

## 📞 Support

For installation issues:

1. Check this guide first
2. Review device logs (Xcode → Devices → Console
3. Verify Apple Developer Portal
4. Check GitHub issue tracker

---

**Version 1.0 | Updated May 2026
