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
            targets: ["DomainApi"]
        ),
    ],
    dependencies: [
        .package(path: "../../CoreKit"),
    ],
    targets: [
        .target(
            name: "DomainApi",
            dependencies: [
                "CoreKit",
            ],
        ),
        .testTarget(
            name: "DomainKitApiTests",
            dependencies: ["DomainApi"]
        )
    ]
)
