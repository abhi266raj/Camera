// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "DomainApi",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "DomainKit.api",            // API only
            targets: ["DomainKit.api"]
        ),
    ],
    dependencies: [
        .package(path: "../../CoreKit"),
        .package(path: "../../PlatformKit")
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
        .testTarget(
            name: "DomainKitApiTests",
            dependencies: ["DomainKit.api"]
        )
    ]
)
