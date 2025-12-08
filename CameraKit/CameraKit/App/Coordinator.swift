//
//  Coordinator.swift
//  CameraKit
//
//  Created by Abhiraj on 30/11/25.
//
import CoreKit

// MARK: - Camera Component (Child)


final class CameraComponentBuilder {

    // Injected service dependencies
    let viewModelServiceProvider: ViewModelDependenciesProvider

    init(viewModelServiceProvider: ViewModelDependenciesProvider = AppDependencies.shared.viewModels) {
        self.viewModelServiceProvider = viewModelServiceProvider
    }

    @MainActor
    func makeCameraView(cameraType: CameraType = .metal) -> CameraView {
        let viewModelDependcies = viewModelServiceProvider.viewModels(for: cameraType)
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

    @MainActor
    func createView(cameraType: CameraType = .metal) -> CameraView {
        componentBuilder.makeCameraView(cameraType: cameraType)
    }
}


