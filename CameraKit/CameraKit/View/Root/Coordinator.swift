//
//  Coordinator.swift
//  CameraKit
//
//  Created by Abhiraj on 30/11/25.
//


// MARK: - Feature Dependency Protocol

protocol CameraDependencies {
    var cameraServices: ServiceDependencies { get }      // Injected
}


// MARK: - Camera Component (Child)

final class CameraComponentBuilder: CameraDependencies {

    // Injected service dependencies
    let cameraServices: ServiceDependencies

    init(services: ServiceDependencies = AppDependencies.shared.services) {
        self.cameraServices = services
    }

    func makeCameraView(cameraType: CameraType = .metal) -> CameraView {
        let config = cameraType.getCameraConfig()
        let service = cameraServices.cameraServiceBuilder.getService(cameraType: cameraType, cameraConfig: config)
        let vm = CameraViewModel(cameraConfig: config, cameraService: service)
        let filterVM = FilterListViewModel(cameraService: service, repository: cameraServices.filterRepository)
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


