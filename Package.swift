// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DebugKit",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "DebugKit", targets: ["DebugKit"]),
    ],
    targets: [
        .target(
            name: "DebugKit",
            path: "Sources",
            dependencies: []),
        .testTarget(
            name: "DebugKitTests",
            dependencies: ["DebugKit"]),
    ]
)
