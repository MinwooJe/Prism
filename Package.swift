// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Prism",
    platforms: [
        .iOS(.v15),             // AsyncStream의 사용을 위해 iOS 15로 설정.
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
