//
//  CameraFacade.swift
//  CameraKit
//
//  Created by Abhiraj on 17/09/23.
//

import Foundation
// import AVFoundation
import Observation
import Combine


@Observable class CameraViewModel {
    
    init(permissionService: PermissionService = CameraPermissionService(), cameraConfig: CameraConfig , cameraService: CameraService) {
        self.permissionService = permissionService
        self.cameraConfig = cameraConfig
        self.cameraService = cameraService
        setup()
    }
    
    init() {
        permissionService = CameraPermissionService()
        let cameraType:CameraType = .camera
        cameraConfig = cameraType.getCameraConfig()
        let serviceBuilder = CameraServiceBuilder()
        cameraService = serviceBuilder.getService(cameraType: cameraType, cameraConfig: cameraConfig)
        setup()
    }
    
    func setup() {
        cameraService.cameraModePublisher.sink { [weak self] mode in
            guard let self else {return }
            self.cameraMode = mode
            if case .active(_) = self.cameraPhase {
                self.cameraPhase = .active(mode)
            }
        }.store(in: &cancellables)
    }
    
    private var cameraMode: CameraMode = .preview
    var cameraPhase: CameraPhase = .inactive
    private var cancellables = Set<AnyCancellable>()
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
                cameraPhase = .active(cameraMode)
            }
        }
    }
    
    func getOutputView() -> CameraContentPreviewService {
        return cameraService.getOutputView()
        
    }
    
    func toggleCamera() async  -> Bool {
        cameraPhase = .switching
        let value =  await cameraService.toggleCamera()
        cameraPhase = .active(cameraMode)
        return value
    }
    
    var cameraOutputState: CameraState  {
        return cameraService.cameraOutputState
    }
    
    func performAction( action: CameraAction) async throws -> Bool {
        return try await cameraService.performAction(action:action)
    }
    
}

