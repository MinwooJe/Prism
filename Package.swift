// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Prism",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "Prism",
            targets: ["Prism"]
        ),
    ],
    targets: [
        .target(
            name: "Prism"
        ),
        .testTarget(
            name: "PrismTests",
            dependencies: ["Prism"]
        ),
    ]
)
