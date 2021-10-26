// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-http-network",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "HTTPNetwork",
            targets: ["HTTPNetwork"]),
        .library(
            name: "HTTPParsing",
            targets: ["HTTPParsing"]),
        .executable(
            name: "send",
            targets: ["send"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "HTTPNetwork",
            dependencies: ["HTTPParsing"]),
        .testTarget(
            name: "HTTPNetworkTests",
            dependencies: ["HTTPNetwork"]),

        .target(
            name: "HTTPParsing",
            dependencies: []),
        .testTarget(
            name: "HTTPParsingTests",
            dependencies: ["HTTPParsing"]),

        .target(
            name: "send",
            dependencies: ["HTTPParsing", "HTTPNetwork"]),
    ]
)
