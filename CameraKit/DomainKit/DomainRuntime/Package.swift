// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "DomainRuntime",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "DomainRuntime",        // Runtime only
            targets: ["DomainKit.runtime"]
        )
    ],
    dependencies: [
        .package(path: "../../CoreKit"),
        .package(path: "../../PlatformKit"),
        .package(path: "../DomainApi")
    ],
    targets: [
        .target(
            name: "DomainKit.runtime",
            dependencies: [
                .product(name: "DomainKit.api", package: "DomainApi"),
                "CoreKit",
                .product(name: "PlatformKit.api", package: "PlatformKit"),
                 .product(name: "PlatformKit.runtime", package: "PlatformKit")
            ],
            path: "Sources/DomainKit.runtime"
        ),
        .testTarget(
            name: "DomainKitRuntimeTests",
            dependencies: ["DomainKit.runtime"]
        )
    ]
)
