// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "PlatformApi",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "PlatformKit.api",       // API-only
            targets: ["PlatformApi"]
        )
    ],
    dependencies: [
        .package(path: "../../CoreKit")
    ],
    targets: [
        .target(
            name: "PlatformApi",
            dependencies: ["CoreKit"],
        ),
        .testTarget(
            name: "PlatformKitTests",
            dependencies: ["PlatformApi"]
        ),
    ]
)
