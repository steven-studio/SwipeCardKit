// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwipeCardKit",
    platforms: [
        .iOS(.v13)  // 支持 iOS 13+
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwipeCardKit",
            targets: ["SwipeCardKit"]
        ),
    ],
    dependencies: [
        // 如果需要外部依赖，在这里添加
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwipeCardKit",
            dependencies: []
        ),
        .testTarget(
            name: "SwipeCardKitTests",
            dependencies: ["SwipeCardKit"]
        ),
    ]
)
