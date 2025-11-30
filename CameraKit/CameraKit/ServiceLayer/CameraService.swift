//
//  CameraPipeline.swift
//  CameraKit
//
//  Created by Abhiraj on 16/10/23.
//

import Foundation


public protocol CameraService {
    func getOutputView() -> CameraContentPreviewService
    func updateSelection(filter: (any FilterModel)?)
    func toggleCamera() async  -> Bool
    var cameraOutputState: CameraOutputState {get}
    func performAction( action: CameraOutputAction) async throws -> Bool
    func setup()
}


class CameraServiceBuilder {
    
    func getService(cameraType: CameraType) -> CameraService
    {
        switch cameraType {
            
        case .camera:
            return CameraPipeline()
        case .basicPhoto:
            return BasicPhotoPipeline()
        case .basicVideo:
            return BasicVideoPipeline()
        case .metal:
            return BasicMetalPipeline()
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
    
    
    var cameraOutputState: CameraOutputState  {
        return output.recordingService.outputState
    }
    
    func performAction( action: CameraOutputAction) async throws -> Bool {
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
    
    
    var cameraOutputState: CameraOutputState  {
        return recordOutput.outputState
    }
    
    func performAction( action: CameraOutputAction) async throws -> Bool {
        return try await recordOutput.performAction(action:action)
    }
    
}
