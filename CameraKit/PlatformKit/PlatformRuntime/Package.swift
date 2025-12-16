// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "PlatformRuntime",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "PlatformKit.runtime",   // Runtime-only
            targets: ["PlatformRuntime"]
        )
    ],
    dependencies: [
        .package(path: "../../CoreKit"),
        .package(path: "../PlatformApi")
    ],
    targets: [
        .target(
            name: "PlatformRuntime",
            dependencies: [
                .product(name: "PlatformKit.api", package: "PlatformApi"),
                "CoreKit"
            ],
        ),
        .testTarget(
            name: "PlatformKitTests",
            dependencies: ["PlatformRuntime"]
        ),
    ]
)
