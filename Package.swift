// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-distributed-utils",
    products: [
        .library(name: "SwiftDistributedUtils", targets: ["SwiftDistributedUtils"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.14.0")
    ],
    targets: [
        .target(
            name: "SwiftDistributedUtils",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
            ]),
        .testTarget(
            name: "SwiftDistributedUtilsTests",
            dependencies: ["SwiftDistributedUtils"]),
    ]
)
