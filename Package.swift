// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftDistributedUtils",
    products: [
        .library(name: "SwiftDistributedUtils", targets: ["SwiftDistributedUtils"])
    ],
    dependencies: [
        .package(url: "https://github.com/daisuke-t-jp/xxHash-Swift.git", from: "1.0.12")
    ],
    targets: [
        .target(
            name: "SwiftDistributedUtils",
            dependencies: ["xxHash-Swift"]),
        .testTarget(
            name: "SwiftDistributedUtilsTests",
            dependencies: ["SwiftDistributedUtils"]),
    ]
)
