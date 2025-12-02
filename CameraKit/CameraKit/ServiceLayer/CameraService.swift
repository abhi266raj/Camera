//
//  CameraPipeline.swift
//  CameraKit
//
//  Created by Abhiraj on 16/10/23.
//

import Foundation
import Observation


public protocol CameraService {
    func getOutputView() -> CameraContentPreviewService
    func updateSelection(filter: (any FilterModel)?)
    func toggleCamera() async  -> Bool
    @ObservationTracked var cameraOutputState: CameraState {get}
    func performAction( action: CameraAction) async throws -> Bool
    func setup()
}


class CameraServiceBuilder {
    
    func getService(cameraType: CameraType, cameraConfig: CameraConfig? = nil) -> CameraService
    {
        let cameraConfig = cameraConfig ?? cameraType.getCameraConfig()
        switch cameraType {
        case .camera:
            return CameraPipeline(cameraOutputAction: cameraConfig.cameraOutputAction)
        case .basicPhoto:
            return BasicPhotoPipeline(cameraOutputAction: cameraConfig.cameraOutputAction)
        case .basicVideo:
            return BasicVideoPipeline(cameraOutputAction: cameraConfig.cameraOutputAction)
        case .metal:
            return BasicMetalPipeline(cameraOutputAction: cameraConfig.cameraOutputAction)
        }
    }
}


protocol CameraPipelineService: CameraService {
    associatedtype PipelineInput: CameraInput
    associatedtype PipelineOutput: CameraOutputService
    associatedtype PipelineProcessor: CameraProccessor
    
    var input: PipelineInput {get}
    var output: PipelineOutput {get}
    var processor: PipelineProcessor {get}    
}


protocol CameraPipelineServiceNew: CameraService {
    associatedtype PipelineInput: CameraInput
    associatedtype PipelinePreviewOutput: CameraContentPreviewService
    associatedtype PipelineRecordingOutput: CameraContentRecordingService
    associatedtype PipelineProcessor: CameraProccessor
    
    var input: PipelineInput {get}
    var previewOutput: PipelinePreviewOutput {get}
    var recordOutput: PipelineRecordingOutput {get }
    var processor: PipelineProcessor {get}
}


extension CameraPipelineService {
    func getOutputView() -> CameraContentPreviewService {
        return output.previewService
        
    }
    
    func updateSelection(filter: (any FilterModel)?)  {
        processor.updateSelection(filter: filter)
    }
    
    
    func toggleCamera() async  -> Bool {
        return await input.toggleCamera()
    }
    
    
    var cameraOutputState: CameraState  {
        return output.recordingService.outputState
    }
    
    func performAction( action: CameraAction) async throws -> Bool {
        return try await output.recordingService.performAction(action:action)
    }
    
}



extension CameraPipelineServiceNew {
    func getOutputView() -> CameraContentPreviewService {
        return previewOutput
    }
    
    func updateSelection(filter: (any FilterModel)?)  {
        processor.updateSelection(filter: filter)
    }
    
    func toggleCamera() async  -> Bool {
        return await input.toggleCamera()
    }
    
    var cameraOutputState: CameraState  {
        return recordOutput.outputState
    }
    
    func performAction( action: CameraAction) async throws -> Bool {
        return try await recordOutput.performAction(action:action)
    }
    
}
