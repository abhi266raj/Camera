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

public enum CameraViewAction: Sendable {
    case pause
    case toggle
    case setup
    case permissionSetup
    case capture(CameraAction)
    case attachDisplay(CameraDisplayTarget)
}

public protocol CameraViewModel: ActionableViewModel {
    @MainActor var viewData: CameraViewData  {get}
    func trigger(_ action: CameraViewAction)
}

public final class CameraViewModelImp: CameraViewModel, @unchecked Sendable {
    
    @MainActor public var viewData: CameraViewData = CameraViewData()
    @MainActor private var cameraMode: CameraMode = .preview
    private let permissionService: PermissionService
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
        let stream =  cameraService.cameraModePublisher
        let task = Task{ @MainActor [weak self]  in
            for await mode in stream {
                guard let self else {
                    return
                }
                await self.cameraMode = mode
                if case .active(_) = self.viewData.cameraPhase {
                    self.viewData.cameraPhase = .active(mode)
                }
            }
        }
    }
    
    deinit {
        
    }
    
    @MainActor
    public func attachDisplay(_ target: CameraDisplayTarget) {
        try? cameraService.attachDisplay(target)
    }
    
    @MainActor public func permissionSetup() async  {
            if viewData.cameraPermissionState == .unknown {
                let permission = await permissionService.requestCameraAndMicrophoneIfNeeded()
                if permission == false {
                    viewData.cameraPermissionState = .denied
                }else {
                    viewData.cameraPermissionState = .authorized
                }
            }
    }
    
     public func setup()   {
         Task {
             Task { @MainActor in
                 if self.viewData.cameraPhase == .paused {
                     self.viewData.cameraPhase = .inactive
                 }
             }
             await try? self.cameraService.perform(.setup)
             Task { @MainActor in
                 self.viewData.cameraPhase = .active(self.cameraMode)
             }
         }
    }
    
    @MainActor
    public func toggleCamera() async  -> Bool {
        viewData.cameraPhase = .switching
        await try? self.cameraService.perform(.toggle)
        viewData.cameraPhase = .active(cameraMode)
        return true
    }
    
    public func performAction( action: CameraAction) async throws -> Bool {
        let map = action.toEngineAction()
        try? await cameraService.perform(map)
        return true
    }
     
    
    public func trigger(_ action: CameraViewAction)  {
        Task {
            switch action {
            case .toggle:
                return await toggleCamera()
                
            case .setup:
                await setup()
                return true
                
            case .permissionSetup:
                await permissionSetup()
                return true
                
            case .capture(let cameraAction):
                return try await performAction(action: cameraAction)
            
            case .attachDisplay(let cameraDisplayTarget):
                 await attachDisplay(cameraDisplayTarget)
                return true
            case .pause:
                await try? self.cameraService.perform(.pause)
                Task { @MainActor in
                    self.viewData.cameraPhase = .paused
                }
                return true
            }
            
        }
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

