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
        .library(name: "UseCaseApi", targets: ["UseCaseApi"]),
        .library(name: "UseCaseRuntime", targets: ["UseCaseRuntime"]),
        .library(name: "WorkFlowApi", targets: ["UseCaseApi", "DomainApi" ]),
        .library(name: "WorkFlowRuntime", targets: ["UseCaseRuntime", "DomainRuntime" ])
        // Add any other targets as needed
    ],
    targets: [
        .target(name: "CoreKit", path: "CameraKit/Core/Sources"),
        .target(name: "DomainApi", dependencies: ["CoreKit"], path: "CameraKit/Business/DomainApi/Sources"),
        .target(name: "DomainRuntime", dependencies: ["CoreKit", "DomainApi", "PlatformApi"], path: "CameraKit/Business/DomainRuntime/Sources"),
        .target(name: "PlatformApi", dependencies: ["CoreKit"], path: "CameraKit/Infra/PlatformApi/Sources"),
        .target(name: "PlatformRuntime", dependencies: ["CoreKit", "PlatformApi"], path: "CameraKit/Infra/PlatformRuntime/Sources"),
        .target(name: "AppViewModel", dependencies: ["DomainApi", "CoreKit", "UseCaseApi"], path: "CameraKit/Presentation/Sources/AppComponents/AppViewModel"),
        .target(name: "AppView", dependencies: ["CoreKit", "AppViewModel"], path: "CameraKit/Presentation/Sources/AppComponents/AppView"),
        .target(name: "UseCaseApi", dependencies: ["CoreKit"], path: "CameraKit/Business/UseCaseApi/Sources"),
        .target(name: "UseCaseRuntime", dependencies: ["CoreKit", "DomainApi", "PlatformApi", "UseCaseApi"], path: "CameraKit/Business/UseCaseRuntime/Sources"),
        // Add test targets as needed
    ]
)
