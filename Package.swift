// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-protocol-based-dependencies",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "ProtocolBasedDependencies",
            targets: ["ProtocolBasedDependencies"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ProtocolBasedDependencies"
        ),
        .testTarget(
            name: "ProtocolBasedDependenciesTests",
            dependencies: [
                "ProtocolBasedDependencies",
            ]
        ),
    ]
)
