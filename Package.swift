// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "CameraKit",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(name: "CoreKit", targets: ["CoreKit"]),
        .library(name: "DomainApi", targets: ["DomainApi"]),
        .library(name: "DomainRuntime", targets: ["DomainRuntime"]),
        .library(name: "PlatformApi", targets: ["PlatformApi"]),
        .library(name: "PlatformRuntime", targets: ["PlatformRuntime"]),
        .library(name: "AppView", targets: ["AppView"]),
        .library(name: "AppViewModel", targets: ["AppViewModel"]),
        // Add any other targets as needed
    ],
    targets: [
        .target(name: "CoreKit", path: "CameraKit/CoreKit/Sources"),
        .target(name: "DomainApi", dependencies: ["CoreKit"], path: "CameraKit/DomainKit/DomainApi/Sources"),
        .target(name: "DomainRuntime", dependencies: ["CoreKit", "DomainApi", "PlatformApi"], path: "CameraKit/DomainKit/DomainRuntime/Sources"),
        .target(name: "PlatformApi", dependencies: ["CoreKit"], path: "CameraKit/PlatformKit/PlatformApi/Sources"),
        .target(name: "PlatformRuntime", dependencies: ["CoreKit", "PlatformApi"], path: "CameraKit/PlatformKit/PlatformRuntime/Sources"),
        .target(name: "AppViewModel", dependencies: ["DomainApi", "CoreKit"], path: "CameraKit/FeatureKit/Sources/AppComponents/AppViewModel"),
        .target(name: "AppView", dependencies: ["CoreKit", "AppViewModel"], path: "CameraKit/FeatureKit/Sources/AppComponents/AppView"),
        // Add test targets as needed
    ]
)
