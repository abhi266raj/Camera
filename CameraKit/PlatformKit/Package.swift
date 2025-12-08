// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "PlatformKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PlatformKit",           // Umbrella
            targets: ["PlatformKit.api", "PlatformKit.runtime"]
        ),
        .library(
            name: "PlatformKit.api",       // API-only
            targets: ["PlatformKit.api"]
        ),
        .library(
            name: "PlatformKit.runtime",   // Runtime-only
            targets: ["PlatformKit.runtime"]
        )
    ],
    dependencies: [
        .package(path: "../CoreKit")
    ],
    targets: [
        .target(
            name: "PlatformKit.api",
            dependencies: ["CoreKit"],
            path: "Sources/PlatformKit.api"
        ),
        .target(
            name: "PlatformKit.runtime",
            dependencies: [
                "PlatformKit.api",
                "CoreKit"
            ],
            path: "Sources/PlatformKit.runtime"
        ),
        .testTarget(
            name: "PlatformKitTests",
            dependencies: ["PlatformKit.runtime"]
        ),
    ]
)
