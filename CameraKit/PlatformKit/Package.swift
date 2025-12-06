// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "PlatformKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PlatformKit",
            type: .dynamic,
            targets: ["PlatformKit"]
        ),
    ],
    dependencies: [
        // Local dependency on CoreKit
        .package(path: "../CoreKit") // ← relative path to CoreKit package
    ],
    targets: [
        .target(
            name: "PlatformKit",
            dependencies: [
                "CoreKit"   // ← target dependency
            ]
        ),
        .testTarget(
            name: "PlatformKitTests",
            dependencies: ["PlatformKit"]
        ),
    ]
)
