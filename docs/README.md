# GitHub iOS App

A secure iOS application featuring GitHub OAuth authentication with Keychain token management, auto-refresh mechanisms, and a beautiful user profile interface.

## ✅ Features Implemented

### 1. OAuth Authentication Module
- GitHub OAuth 2.0 flow integration
- Safari Services for secure web authentication
- Configurable authentication parameters (client ID, scopes, redirect URI)
- Delegate pattern for authentication state callbacks

### 2. Token Security & Keychain Storage
- Secure token storage using iOS Keychain Services
- `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` protection level
- Token persistence across app launches
- Encoded token storage with proper error handling

### 3. Auto-Refresh Mechanism
- Automatic token refresh timer (checks every 60 seconds)
- Refresh threshold at 80% of token lifespan
- Thread-safe refresh operations (prevents duplicate refresh requests)
- Delegate callbacks for refresh status

### 4. Login Page UI & Logic
- Beautiful gradient background design
- Animated loading states during authentication
- Clean typography with modern iOS styling
- Error handling and user feedback

### 5. User Information Module
- User profile display with avatar
- Statistics: Repos, Followers, Following
- User bio, company, location, blog
- Join date formatting
- Image caching system for avatar
- Logout functionality with confirmation

## 📁 Project Structure

```
GitHub-iOS-App/
├── Sources/
│   ├── App/
│   │   ├── AppDelegate.swift          # App entry point & URL handling
│   │   └── MainViewController.swift   # Root controller with auth state management
│   ├── Auth/
│   │   ├── GitHubAuthConfig.swift     # OAuth configuration
│   │   ├── GitHubAuthManager.swift    # Authentication flow manager
│   │   └── TokenRefreshManager.swift  # Auto-refresh mechanism
│   ├── Keychain/
│   │   └── KeychainManager.swift      # Secure Keychain operations
│   ├── Networking/
│   │   └── GitHubAPIClient.swift      # API client with auto-refresh support
│   ├── UserInfo/
│   │   ├── GitHubUser.swift           # User data models
│   │   └── UserService.swift          # User API service + image cache
│   └── UserInterface/
│       ├── LoginViewController.swift  # Login screen
│       └── ProfileViewController.swift # Profile screen
├── Package.swift                      # Swift Package Manager config
├── Info.plist                         # App configuration (URL scheme)
└── README.md
```

## 🛡️ Security Features

1. **Keychain Storage**: Tokens are securely stored in the iOS Keychain, not in `UserDefaults`
2. **Auto-Refresh**: Tokens automatically refresh before expiry (80% threshold)
3. **Token Expiry Check**: Each API call validates token freshness
4. **Background Token Refresh**: Timer-based refresh checks
5. **Authorization Header Injection**: Automatic Bearer token injection for API requests

## 🚀 Usage

### Setup GitHub OAuth Application

1. Go to [GitHub Developer Settings](https://github.com/settings/developers)
2. Create a new OAuth application
3. Set Authorization callback URL to: `githubapp://callback`
4. Copy your Client ID and Client Secret

### Configure in App

Update `AppDelegate.swift`:

```swift
let config = GitHubAuthConfig(
    clientId: "YOUR_CLIENT_ID",
    clientSecret: "YOUR_CLIENT_SECRET",
    redirectUri: "githubapp://callback",
    scopes: ["user", "repo", "notifications"]
)
GitHubAuthManager.shared.configure(with: config)
```

### Authentication Flow

```swift
// Start authentication
GitHubAuthManager.shared.authenticate(from: viewController) { result in
    switch result {
    case .success(let token):
        print("Authenticated with token: \(token.accessToken)")
    case .failure(let error):
        print("Auth failed: \(error)")
    }
}
```

### Handle Callback

URL handling is already set up in `AppDelegate.swift`:

```swift
func application(_ app: UIApplication, open url: URL, options: [:]) -> Bool {
    if url.scheme == "githubapp" {
        GitHubAuthManager.shared.handleCallback(url: url)
        return true
    }
    return false
}
```

### Fetch User Profile

```swift
Task {
    do {
        let user = try await UserService.shared.fetchCurrentUser()
        print("Welcome, \(user.displayName)!")
    } catch {
        print("Error: \(error)")
    }
}
```

### Check Authentication Status

```swift
if GitHubAuthManager.shared.isAuthenticated {
    // User is logged in
    let token = GitHubAuthManager.shared.currentToken
}
```

### Logout

```swift
GitHubAuthManager.shared.logout()
```

## 📊 Token Management

- **Token Validation**: `token.isExpired` - Check if token is expired
- **Refresh Needed**: `token.needsRefresh` - Check if token should be refreshed
- **Auto-Refresh**: Timer runs every 60 seconds, refreshes when 80% of lifespan reached
- **Manual Refresh**: `TokenRefreshManager.shared.refreshToken()`

## 🎨 UI Components

### LoginViewController
- Gradient background
- Animated button states
- Activity indicator
- Status feedback labels

### ProfileViewController
- Circular avatar with async loading
- Name + @username display
- Bio section
- Stats grid (Repos, Followers, Following)
- Info rows with SF Symbols icons
- Logout button with confirmation alert

## 🔄 API Client Features

- Async/await API calls
- Automatic token refresh on 401 responses
- Request retry after successful refresh
- Response validation and error handling
- Image download support

## 📦 Dependencies

- **UIKit**: iOS UI framework
- **SafariServices**: Secure web view for OAuth
- **Security**: Keychain Services
- **Foundation**: Basic iOS frameworks

## ⚙️ Requirements

- iOS 16.0+
- Swift 5.9+
- Xcode 15.0+

## 🔐 Keychain Security

The Keychain implementation uses:
- `kSecClassGenericPassword` class for generic password items
- `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` - Only accessible when device is unlocked, not included in backups
- No hardcoded secrets - credentials must be configured by developer

## 📝 License

MIT License - feel free to use this in your projects!

---

**Developed by C** ✨
