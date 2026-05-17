// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GitHubiOS",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "GitHubiOS",
            targets: ["GitHubiOS"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/CombineCommunity/CombineExt.git", from: "1.8.0")
    ],
    targets: [
        .target(
            name: "GitHubiOS",
            dependencies: [
                .product(name: "CombineExt", package: "CombineExt")
            ],
            path: "."
        ),
        .testTarget(
            name: "GitHubiOSTests",
            dependencies: ["GitHubiOS"],
            path: "Tests"
        )
    ]
)
