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
import DomainKit_api


public enum PermissionStatus {
    case unknown
    case authorized
    case denied
}


@Observable public class CameraViewModel: @unchecked Sendable {
    
    @MainActor private var cameraMode: CameraMode = .preview
    @MainActor public var cameraPhase: CameraPhase = .inactive
    private var cancellables = Set<AnyCancellable>()
    // private let cameraConfig: CameraConfig
    private let permissionService: PermissionService
    public var cameraPermissionState: PermissionStatus = .unknown
    private let cameraService:CameraEngine
    
    public init(permissionService: PermissionService, cameraService: CameraEngine) {
        self.permissionService = permissionService
       // self.cameraConfig = cameraConfig
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
    
    @MainActor
    public func attachDisplay(_ target: CameraDisplayTarget) {
        try? cameraService.attachDisplay(target)
    }
    
    public var showMultiCam: Bool {
        return cameraService.activeConfig.display == .multicam
    }

    
    public var showCamera: Bool {
        return cameraService.activeConfig.storage == .photo
    }
    
    public var showFilter: Bool {
        cameraService.activeConfig.inputOutput.contains(.ciFilter) || cameraService.activeConfig.inputOutput.contains(.metalFilter)
    }
    
    public var showRecording: Bool {
        cameraService.activeConfig.storage == .video
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
         //await self.cameraService.setup()
         await try? self.cameraService.perform(.setup)
          Task { @MainActor in
               self.cameraPhase = .active(self.cameraMode)
          }
    }
    
    @MainActor
    public func toggleCamera() async  -> Bool {
        cameraPhase = .switching
        await try? self.cameraService.perform(.toggle)
        //let value =  await cameraService.toggleCamera()
        cameraPhase = .active(cameraMode)
        return true
    }
    
    public func performAction( action: CameraAction) async throws -> Bool {
        let map = action.toEngineAction()
        try? await cameraService.perform(map)
        return true
    }
    
}

extension CameraAction {
    func toEngineAction() -> EngineAction {
        if self == .photo {
            return .takePicture
        }
        
        if self == .startRecord {
            return .startRecording
        }
        
        return .stopRecording
    }
}

