//
//  Coordinator.swift
//  CameraKit
//
//  Created by Abhiraj on 30/11/25.
//



struct CameraCoordinator {
    
    func createView(cameraType: CameraType = .metal) -> CameraView {
        let viewModel = CameraViewModel(cameraType: cameraType)
        let view = CameraView(viewModel: viewModel)
        return view
    }
}

