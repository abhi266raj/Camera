//
//  CameraFacade.swift
//  CameraKit
//
//  Created by Abhiraj on 17/09/23.
//

import Foundation
import Observation
import CoreKit
import DomainApi
internal import Combine


public enum PermissionStatus {
    case unknown
    case authorized
    case denied
}

@MainActor
@Observable public class CameraViewData: Sendable {
    public var cameraPhase: CameraPhase = .inactive
    public var cameraPermissionState: PermissionStatus = .unknown
    public var showMultiCam: Bool = false
    public var showPhotoCapture: Bool = false
    public var showFilter: Bool = false
    public var showRecording: Bool = false
    
}





@Observable public class CameraViewModel: @unchecked Sendable {
    
    @MainActor public var viewData: CameraViewData = CameraViewData()
    
    @MainActor private var cameraMode: CameraMode = .preview
   // @MainActor public var cameraPhase: CameraPhase = .inactive
    private var cancellables = Set<AnyCancellable>()
    // private let cameraConfig: CameraConfig
    private let permissionService: PermissionService
    //public var cameraPermissionState: PermissionStatus = .unknown
    private let cameraService:CameraEngine
    
    @MainActor
    public init(permissionService: PermissionService, cameraService: CameraEngine) {
        self.permissionService = permissionService
       // self.cameraConfig = cameraConfig
        self.cameraService = cameraService
        updateViewData()
        commonInit()
    }
    
    
    @MainActor func updateViewData() {
        let config = cameraService.activeConfig
        viewData.showMultiCam = (config.display == .multicam)
        viewData.showPhotoCapture = (config.storage == .photo)
        viewData.showFilter =
        config.inputOutput.contains(.ciFilter) ||
        config.inputOutput.contains(.metalFilter)
        viewData.showRecording = (config.storage == .video)
        
    }
    
    func commonInit() {
        cameraService.cameraModePublisher
            .sink {  [weak self] mode in
            guard let self else {return }
                Task { @MainActor in
                    self.cameraMode = mode
                    if case .active(_) = self.viewData.cameraPhase {
                        self.viewData.cameraPhase = .active(mode)
                    }
                }
        }.store(in: &cancellables)
    }
    
    @MainActor
    public func attachDisplay(_ target: CameraDisplayTarget) {
        try? cameraService.attachDisplay(target)
    }
    
//    public var showMultiCam: Bool {
//        return cameraService.activeConfig.display == .multicam
//    }
//
//    
//    public var showCamera: Bool {
//        return cameraService.activeConfig.storage == .photo
//    }
//    
//    public var showFilter: Bool {
//        cameraService.activeConfig.inputOutput.contains(.ciFilter) || cameraService.activeConfig.inputOutput.contains(.metalFilter)
//    }
//    
//    public var showRecording: Bool {
//        cameraService.activeConfig.storage == .video
//    }
    
    @MainActor public func permissionSetup() async {
        if viewData.cameraPermissionState == .unknown {
            let permission = await permissionService.requestCameraAndMicrophoneIfNeeded()
            if permission == false {
                viewData.cameraPermissionState = .denied
            }else {
                viewData.cameraPermissionState = .authorized
            }
        }
        
    }
    
     public func setup() async  {
         //await self.cameraService.setup()
         await try? self.cameraService.perform(.setup)
          Task { @MainActor in
              self.viewData.cameraPhase = .active(self.cameraMode)
          }
    }
    
    @MainActor
    public func toggleCamera() async  -> Bool {
        viewData.cameraPhase = .switching
        await try? self.cameraService.perform(.toggle)
        //let value =  await cameraService.toggleCamera()
        viewData.cameraPhase = .active(cameraMode)
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

