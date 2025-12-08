// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "FeatureKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AppView",
            targets: ["AppView"]
        ),
        .library(
            name: "AppViewModel",
            targets: ["AppViewModel"]
        )
    ],
    dependencies: [
        .package(path: "../CoreKit"),
        .package(path: "../DomainKit")
    ],
    targets: [
        // ViewModel target depends on DomainKit.api & DomainKit.runtime
        .target(
            name: "AppViewModel",
            dependencies: [
                .product(name: "DomainKit.api", package: "DomainKit"),
                // .product(name: "DomainKit.runtime", package: "DomainKit")
            ],
            path: "Sources/AppComponents/AppViewModel"
        ),
        // View target depends on CoreKit and ViewModel
        .target(
            name: "AppView",
            dependencies: ["CoreKit", "AppViewModel"],
            path: "Sources/AppComponents/AppView"
        ),
        // Test targets
        .testTarget(
            name: "AppViewTests",
            dependencies: ["AppView"]
        ),
        .testTarget(
            name: "AppViewModelTests",
            dependencies: ["AppViewModel"]
        )
    ]
)
