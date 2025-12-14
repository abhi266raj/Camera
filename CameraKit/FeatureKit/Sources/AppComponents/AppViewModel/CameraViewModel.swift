//
//  CameraFacade.swift
//  CameraKit
//
//  Created by Abhiraj on 17/09/23.
//

import Foundation
import Observation
import Combine
import CoreKit
import PlatformKit_api
import DomainKit_api
// import DomainKit_runtime

@Observable public class CameraViewModel: @unchecked Sendable {
    
    public init(permissionService: PermissionService, cameraConfig: CameraConfig , cameraService: CameraEngine) {
        self.permissionService = permissionService
        self.cameraConfig = cameraConfig
        self.cameraService = cameraService
        commonInit()
    }
    
    func commonInit() {
        cameraService.cameraModePublisher
            .sink {  [weak self] mode in
            guard let self else {return }
                Task { @MainActor in
                    self.cameraMode = mode
                    if case .active(_) = self.cameraPhase {
                        self.cameraPhase = .active(mode)
                    }
                }
        }.store(in: &cancellables)
    }
    
    @MainActor private var cameraMode: CameraMode = .preview
    @MainActor public var cameraPhase: CameraPhase = .inactive
    private var cancellables = Set<AnyCancellable>()
    private let cameraConfig: CameraConfig
    private let permissionService: PermissionService
    public var cameraPermissionState: PermissionStatus = .unknown
    private let cameraService:CameraEngine
    
    @MainActor
    public func attachDisplay(_ target: CameraDisplayTarget) {
        try? cameraService.attachDisplay(target)
    }
    
    public var showMultiCam: Bool {
        return cameraConfig.renderMode == .mutliCam
    }

    
    public var showCamera: Bool {
        return cameraConfig.supportedTask == .capturePhoto
    }
    
    public var showFilter: Bool {
        return cameraConfig.renderMode == .metal
    }
    
    public var showRecording: Bool {
        return cameraConfig.supportedTask == .recordVideo
    }
    
    @MainActor public func permissionSetup() async {
        if cameraPermissionState == .unknown {
            let permission = await permissionService.requestCameraAndMicrophoneIfNeeded()
            if permission == false {
                cameraPermissionState = .denied
            }else {
                cameraPermissionState = .authorized
            }
        }
        
    }
    
     public func setup() async  {
         await self.cameraService.setup()
          Task { @MainActor in
               self.cameraPhase = .active(self.cameraMode)
          }
    }
    
    @MainActor
    public func toggleCamera() async  -> Bool {
        cameraPhase = .switching
        let value =  await cameraService.toggleCamera()
        cameraPhase = .active(cameraMode)
        return value
    }
    
    public func performAction( action: CameraAction) async throws -> Bool {
        return try await cameraService.performAction(action:action)
    }
    
}

