// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Frankfurter",
    platforms: [
        .iOS(.v13),
        .macOS(.v12),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "Frankfurter",
            targets: ["Frankfurter"]
        ),
    ],
    targets: [
        .target(
            name: "Frankfurter"),
        .testTarget(
            name: "FrankfurterTests",
            dependencies: ["Frankfurter"]
        ),
    ]
)
