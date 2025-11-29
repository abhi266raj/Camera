//
//  CameraFacade.swift
//  CameraKit
//
//  Created by Abhiraj on 17/09/23.
//

import Foundation
import AVFoundation
import Observation


enum CameraState {
    case unknown
    case permissionDenied
    case active
    case paused
}


@Observable class CameraViewModel {
    
    init(permissionService: PermissionService = CameraPermissionService(), cameraInputManger: any CameraPipelineService = BasicPhotoPipeline()) {
        self.permissionService = permissionService
        self.cameraInputManger = cameraInputManger
    }
    
    private let permissionService: PermissionService
    var state: CameraState = .unknown
    private let cameraInputManger: any CameraPipelineService
    
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
    
    func getOutputView() -> CameraOutput {
        return cameraInputManger.output
        
    }
    
    func updateSelection(filter: (any FilterModel)?)  {
        cameraInputManger.processor.updateSelection(filter: filter)
    }
    
    
    func toggleCamera() async  -> Bool {
        return await cameraInputManger.input.toggleCamera()
    }
    
    
    var cameraOutputState: CameraOutputState  {
        return cameraInputManger.output.outputState
    }
    
    func performAction( action: CameraOutputAction) async throws -> Bool {
        return try await cameraInputManger.output.performAction(action:action)
    }
    
}

