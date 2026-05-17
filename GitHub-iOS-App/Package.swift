// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GitHub-iOS-App",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "GitHubApp",
            targets: ["GitHubApp"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GitHubApp",
            path: "Sources"
        )
    ]
)
