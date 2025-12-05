//
//  Coordinator.swift
//  CameraKit
//
//  Created by Abhiraj on 30/11/25.
//


// MARK: - Feature Dependency Protocol

protocol CameraDependencies {
    var viewModelServiceProvider: ViewModelDependenciesProvider { get }      // Injected
}


// MARK: - Camera Component (Child)

final class CameraComponentBuilder: CameraDependencies {

    // Injected service dependencies
    let viewModelServiceProvider: ViewModelDependenciesProvider

    init(viewModelServiceProvider: ViewModelDependenciesProvider = AppDependencies.shared.viewModelServiceProvider) {
        self.viewModelServiceProvider = viewModelServiceProvider
    }

    func makeCameraView(cameraType: CameraType = .metal) -> CameraView {
        let viewModelDependcies = viewModelServiceProvider.viewModelDependenciesFor(cameraType: cameraType)
        let vm = viewModelDependcies.cameraViewModel
        let filterVM = viewModelDependcies.filterListViewModel
        return CameraView(viewModel: vm, filterListViewModel: filterVM)
    }
}


// MARK: - Coordinator

struct CameraCoordinator {
    private let componentBuilder: CameraComponentBuilder

    init(componentBuilder: CameraComponentBuilder = CameraComponentBuilder()) {
        self.componentBuilder = componentBuilder
    }

    func createView(cameraType: CameraType = .metal) -> CameraView {
        componentBuilder.makeCameraView(cameraType: cameraType)
    }
}


