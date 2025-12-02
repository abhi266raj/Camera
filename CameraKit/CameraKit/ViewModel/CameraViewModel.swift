//
//  CameraFacade.swift
//  CameraKit
//
//  Created by Abhiraj on 17/09/23.
//

import Foundation
// import AVFoundation
import Observation


enum CameraState {
    case unknown
    case permissionDenied
    case active
    case paused
}


@Observable class CameraViewModel {
    
    init(permissionService: PermissionService = CameraPermissionService(), cameraType: CameraType = .camera) {
        self.permissionService = permissionService
        self.cameraConfig = cameraType.getCameraConfig()
        let serviceBuilder = CameraServiceBuilder()
        self.cameraInputManger = serviceBuilder.getService(cameraType: cameraType, cameraConfig: cameraConfig)
        
    }
    
    private let cameraConfig: CameraConfig
    private let permissionService: PermissionService
    var state: CameraState = .unknown
    private let cameraInputManger: any CameraService
    
    var showCamera: Bool {
        return cameraConfig.supportedTask == .capturePhoto
    }
    
    var showFilter: Bool {
        return cameraConfig.renderMode == .metal
    }
    
    var showRecording: Bool {
        return cameraConfig.supportedTask == .recordVideo
    }
    
    
    @MainActor public func setup() async {
        if state == .unknown {
            let permission = await permissionService.requestCameraAndMicrophoneIfNeeded()
            if permission == false {
                self.state = .permissionDenied
            }else {
                cameraInputManger.setup()
                self.state = .active
            }
        }
    }
    
    func getOutputView() -> CameraContentPreviewService {
        return cameraInputManger.getOutputView()
        
    }
    
    func updateSelection(filter: (any FilterModel)?)  {
        cameraInputManger.updateSelection(filter: filter)
    }
    
    
    func toggleCamera() async  -> Bool {
        return await cameraInputManger.toggleCamera()
    }
    
    
    var cameraOutputState: CameraOutputState  {
        return cameraInputManger.cameraOutputState
    }
    
    func performAction( action: CameraAction) async throws -> Bool {
        return try await cameraInputManger.performAction(action:action)
    }
    
}

