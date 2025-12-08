// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "DomainKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "DomainKit",                // Umbrella
            targets: ["DomainKit.api", "DomainKit.runtime"]
        ),
        .library(
            name: "DomainKit.api",            // API only
            targets: ["DomainKit.api"]
        ),
        .library(
            name: "DomainKit.runtime",        // Runtime only
            targets: ["DomainKit.runtime"]
        )
    ],
    dependencies: [
        .package(path: "../CoreKit"),
        .package(path: "../PlatformKit")
    ],
    targets: [
        .target(
            name: "DomainKit.api",
            dependencies: [
                "CoreKit",
                .product(name: "PlatformKit.api", package: "PlatformKit")
            ],
            path: "Sources/DomainKit.api"
        ),
        .target(
            name: "DomainKit.runtime",
            dependencies: [
                "DomainKit.api",
                "CoreKit",
                .product(name: "PlatformKit.api", package: "PlatformKit"),
                // .product(name: "PlatformKit.runtime", package: "PlatformKit")
            ],
            path: "Sources/DomainKit.runtime"
        ),
        .testTarget(
            name: "DomainKitTests",
            dependencies: ["DomainKit.runtime"]
        )
    ]
)
