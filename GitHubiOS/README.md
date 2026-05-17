# GitHub iOS App - Clean Architecture Implementation

## Project Structure

```
GitHubiOS/
├── Network/                    # Network Layer
│   ├── NetworkError.swift      # Error handling
│   ├── TokenManager.swift      # Token management (Keychain)
│   ├── RequestInterceptor.swift # Request interceptors (Auth, Logging)
│   ├── NetworkClient.swift     # Network client with Combine support
│   └── Endpoint.swift          # API endpoint definitions
├── Domain/                     # Domain Layer (Business Logic)
│   ├── Repository.swift        # Repository model
│   └── RepositoryRepository.swift # Repository protocol
├── DData/                      # Data Layer
│   ├── Remote/                 # Remote Data Source
│   │   └── RepositoryRemoteDataSource.swift
│   ├── Local/                  # Local Data Source (UserDefaults cache)
│   │   └── RepositoryLocalDataSource.swift
│   └── Repository/             # Repository Implementation
│       └── RepositoryRepositoryImpl.swift
├── Presentation/               # Presentation Layer
│   └── RepositoriesViewModel.swift # ViewModel for repository list
└── Package.swift               # Swift Package Manager configuration
```

## Architecture Overview

### 1. Network Layer
- **Error Handling**: `NetworkError` enum with localized descriptions
- **Token Management**: `TokenManager` handles GitHub OAuth token storage in Keychain
- **Request Interception**: `AuthInterceptor` adds Authorization header, `LoggingInterceptor` for debug logging
- **Network Client**: `NetworkClient` uses Combine for reactive network calls, with automatic JSON decoding
- **Endpoint Definitions**: Type-safe API endpoints with HTTP methods, parameters, and headers

### 2. Data Layer (Repository Pattern)
- **Remote Data Source**: Fetches data from GitHub REST API
- **Local Data Source**: Caches data in UserDefaults (configurable for Core Data)
- **Repository Implementation**: Implements domain protocol, provides single source of truth with cache-then-network strategy

### 3. Domain Layer
- **Models**: Pure Swift models representing business entities
- **Protocols**: Repository protocols defining data access contracts

### 4. Presentation Layer
- **ViewModel**: Combine-powered ViewModel for repository list, handles pagination and refresh

## Key Features

✅ **Clean Architecture**: Separation of concerns, testable, maintainable
✅ **Combine Support**: Reactive programming for data flow
✅ **Keychain Storage**: Secure token management
✅ **Cache Strategy**: Cache-then-network for offline support
✅ **Type-Safe APIs**: Endpoint enum prevents runtime errors
✅ **Error Handling**: Comprehensive error handling with user-friendly messages
✅ **Pagination Support**: Built-in pagination for repository lists
✅ **Logging**: Debug logging for network requests/responses

## Usage

### 1. Save OAuth Token
```swift
try TokenManager.shared.saveToken("github_oauth_token")
```

### 2. Fetch Repositories
```swift
let viewModel = RepositoriesViewModel()
viewModel.fetchRepositories()

// Access repositories
viewModel.repositories // [Repository]
```

### 3. Search Repositories
```swift
let repository = RepositoryRepositoryImpl()
repository.searchRepositories(query: "swift", perPage: 20, page: 1)
    .sink(receiveCompletion: { _ in }, receiveValue: { response in
        print("Found \(response.totalCount) repositories")
    })
    .store(in: &cancellables)
```

## Dependencies

- **CombineExt**: Combine utilities (https://github.com/CombineCommunity/CombineExt)

## Build

```bash
cd GitHubiOS
swift build
```

## Next Steps

1. Add Core Data support for local storage
2. Implement authentication flow
3. Add more API endpoints (issues, pull requests, users)
4. Add unit tests for each layer
5. Implement UI layer with SwiftUI
