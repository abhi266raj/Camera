//
//  Coordinator.swift
//  CameraKit
//
//  Created by Abhiraj on 30/11/25.
//



struct CameraCoordinator {
    
    func createView(cameraType: CameraType = .metal) -> CameraView {
        let cameraConfig = cameraType.getCameraConfig()
        let serviceBuilder = CameraServiceBuilder()
        let cameraService = serviceBuilder.getService(cameraType: cameraType, cameraConfig: cameraConfig)
        let viewModel = CameraViewModel(cameraConfig: cameraConfig, cameraService: cameraService)
        let filterListViewModel = FilterListViewModel(cameraService: cameraService)
        let view = CameraView(viewModel: viewModel, filterListViewModel: filterListViewModel)
        return view
    }
}

