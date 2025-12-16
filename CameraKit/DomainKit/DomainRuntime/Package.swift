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
            targets: ["DomainRuntime"]
        )
    ],
    dependencies: [
        .package(path: "../../CoreKit"),
        .package(path: "../../PlatformKit"),
        .package(path: "../DomainApi")
    ],
    targets: [
        .target(
            name: "DomainRuntime",
            dependencies: [
                .product(name: "DomainKit.api", package: "DomainApi"),
                "CoreKit",
                .product(name: "PlatformKit.api", package: "PlatformKit"),
                 .product(name: "PlatformKit.runtime", package: "PlatformKit")
            ],
        ),
        .testTarget(
            name: "DomainKitRuntimeTests",
            dependencies: ["DomainRuntime"]
        )
    ]
)
