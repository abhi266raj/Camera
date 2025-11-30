//
//  CameraPipeline.swift
//  CameraKit
//
//  Created by Abhiraj on 16/10/23.
//

import Foundation


public protocol CameraService {
    func getOutputView() -> CameraOutputService
    func updateSelection(filter: (any FilterModel)?)
    func toggleCamera() async  -> Bool
    var cameraOutputState: CameraOutputState {get}
    func performAction( action: CameraOutputAction) async throws -> Bool
    func setup()
}


public protocol CameraPipelineService: CameraService {
    associatedtype PipelineInput: CameraInput
    associatedtype PipelineOutput: CameraOutputService
    associatedtype PipelineProcessor: CameraProccessor
    
    var input: PipelineInput {get}
    var output: PipelineOutput {get}
    var processor: PipelineProcessor {get}    
}


extension CameraPipelineService {
    func getOutputView() -> CameraOutputService {
        return output
        
    }
    
    func updateSelection(filter: (any FilterModel)?)  {
        processor.updateSelection(filter: filter)
    }
    
    
    func toggleCamera() async  -> Bool {
        return await input.toggleCamera()
    }
    
    
    var cameraOutputState: CameraOutputState  {
        return output.outputState
    }
    
    func performAction( action: CameraOutputAction) async throws -> Bool {
        return try await output.performAction(action:action)
    }
    
}
