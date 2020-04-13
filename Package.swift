// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftDistributedUtils",
    products: [
        .library(name: "SwiftDistributedUtils", targets: ["SwiftDistributedUtils"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SwiftDistributedUtils",
            dependencies: []),
        .testTarget(
            name: "SwiftDistributedUtilsTests",
            dependencies: ["SwiftDistributedUtils"]),
    ]
)
