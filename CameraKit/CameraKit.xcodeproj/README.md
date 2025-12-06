// CameraKit

// CameraKit is a modular Swift/iOS framework designed to provide advanced camera and filter management with a clean dependency injection architecture.

// Features
// - Modular architecture using dependency injection (DI)
// - Easy integration of camera and filter services
// - Extensible for custom views and services
// - Built with SwiftUI and modern Swift best practices

// Architecture Overview
// - ServiceDependencies and ViewDependencies protocols define the app's injectable services and views.
// - ServiceComponent implements core service dependencies (repositories, builders).
// - ViewComponent implements view creation (camera, filter views).
// - AppDependencies is a singleton for global access.

// Getting Started
// 1. Clone this repository.
// 2. Open the Xcode project.
// 3. Explore the AppDI.swift for dependency setup and see how to inject/extend functionality.

// Example Usage
// let cameraView = ViewComponent().createCameraView()
// let filterView = ViewComponent().createFilterView()

// Contributing
// - Feel free to open pull requests and issues to improve CameraKit!

// License
// MIT License
