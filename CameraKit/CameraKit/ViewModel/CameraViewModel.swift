//
//  CameraFacade.swift
//  CameraKit
//
//  Created by Abhiraj on 17/09/23.
//

import Foundation
// import AVFoundation
import Observation


@Observable class CameraViewModel {
    
    init(permissionService: PermissionService = CameraPermissionService(), cameraConfig: CameraConfig , cameraService: CameraService) {
        self.permissionService = permissionService
        self.cameraConfig = cameraConfig
        self.cameraService = cameraService
    }
    
    init() {
        permissionService = CameraPermissionService()
        let cameraType:CameraType = .camera
        cameraConfig = cameraType.getCameraConfig()
        let serviceBuilder = CameraServiceBuilder()
        cameraService = serviceBuilder.getService(cameraType: cameraType, cameraConfig: cameraConfig)
    }
    
    private let cameraConfig: CameraConfig
    private let permissionService: PermissionService
    var cameraPermissionState: PermissionStatus = .unknown
    private let cameraService:CameraService
    
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
        if cameraPermissionState == .unknown {
            let permission = await permissionService.requestCameraAndMicrophoneIfNeeded()
            if permission == false {
                cameraPermissionState = .denied
            }else {
                cameraService.setup()
                cameraPermissionState = .authorized
            }
        }
    }
    
    func getOutputView() -> CameraContentPreviewService {
        return cameraService.getOutputView()
        
    }
    
    func toggleCamera() async  -> Bool {
        return await cameraService.toggleCamera()
    }
    
    var cameraOutputState: CameraState  {
        return cameraService.cameraOutputState
    }
    
    func performAction( action: CameraAction) async throws -> Bool {
        return try await cameraService.performAction(action:action)
    }
    
}

