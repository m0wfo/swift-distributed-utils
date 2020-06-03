// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftDistributedUtils",
    products: [
        .library(name: "SwiftDistributedUtils", targets: ["SwiftDistributedUtils"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.14.0"),
        .package(url: "https://github.com/allegro/swift-junit.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SwiftDistributedUtils",
            dependencies: ["Logging", "NIO", "NIOHTTP1"]),
        .target(
            name: "IntegrationTestRunner",
            dependencies: ["SwiftDistributedUtils"]),
        .testTarget(
            name: "SwiftDistributedUtilsTests",
            dependencies: ["SwiftDistributedUtils", "SwiftTestReporter"]),
    ]
)
