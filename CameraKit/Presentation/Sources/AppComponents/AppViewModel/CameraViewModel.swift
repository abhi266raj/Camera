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

public final class CameraViewModelImp: CameraViewModel {
    
    @MainActor public var viewData: CameraViewData = CameraViewData()
    @MainActor private var cameraMode: CameraMode = .preview
    private let permissionService: PermissionService
    private let cameraService:CameraEngine
    
    private let continuation: AsyncStream<CameraViewAction>.Continuation
    private let stream: AsyncStream<CameraViewAction>
    
    
    @MainActor
    public init(permissionService: PermissionService, cameraService: CameraEngine) {
        self.permissionService = permissionService
        self.cameraService = cameraService
        (stream,continuation) = AsyncStream<CameraViewAction>.make()
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
    
    @MainActor
    func commonInit() {
        Task.immediate {
            await listenCameraMode()
        }
        
        Task.immediate {
            await listenStreamAction()
        }
    }
    
    @MainActor
    func listenCameraMode() async {
        let stream =  cameraService.cameraMode
        for await mode in stream {
            await self.cameraMode = mode
            if case .active(_) = self.viewData.cameraPhase {
                self.viewData.cameraPhase = .active(mode)
            }
        }
        
    }
    
    @MainActor
    func listenStreamAction() async {
        for await action in self.stream {
            await perform(action)
        }
    }
    
    deinit {
        
    }
    
    @MainActor
    public func attachDisplay(_ target: CameraDisplayTarget) async
    {
        try? await cameraService.attachDisplay(target)
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
    
    @MainActor func setup() async {
        if self.viewData.cameraPhase == .paused {
            self.viewData.cameraPhase = .inactive
        }
        await try? self.cameraService.perform(.setup)
        self.viewData.cameraPhase = .active(self.cameraMode)
    }
    
    
    @MainActor
    public func toggleCamera() async  {
        viewData.cameraPhase = .switching
        await try? self.cameraService.perform(.toggle)
        viewData.cameraPhase = .active(cameraMode)
    }
    
    @MainActor
    public func performAction( action: CameraAction) async throws {
        let map = action.toEngineAction()
        try? await cameraService.perform(map)
    }
     
    
    public func trigger(_ action: CameraViewAction)  {
        continuation.yield(action)
    }
    
    @MainActor
    func perform(_ action: CameraViewAction) async {
        switch action {
        case .toggle:
            await toggleCamera()
            
        case .setup:
            await setup()
        
        case .permissionSetup:
            await permissionSetup()
          
        case .capture(let cameraAction):
             try? await performAction(action: cameraAction)
            
        case .attachDisplay(let cameraDisplayTarget):
            await attachDisplay(cameraDisplayTarget)

        case .pause:
            await pause()
        }
    }
    
    @MainActor
    func pause() async {
        await try? self.cameraService.perform(.pause)
        self.viewData.cameraPhase = .paused
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

