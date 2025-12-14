//
//  CameraPipelineServiceLegacy.swift
//  DomainKit
//
//  Created by Abhiraj on 14/12/25.
//

import CoreKit
import PlatformKit_api
import DomainKit_api
import Combine
import CoreMedia
import PlatformKit_runtime

public protocol CameraPipelineServiceLegacy: CameraEngine {
    associatedtype PipelineInput
    associatedtype PipelineDisplayCoordinator: CameraDisplayCoordinator
    associatedtype PipelineRecordingOutput: CameraDiskOutputService
    associatedtype PipelineProcessor =  Void
    
    var input: PipelineInput {get}
    var displayCoordinator: PipelineDisplayCoordinator {get}
    var recordOutput: PipelineRecordingOutput {get }
    var processor: PipelineProcessor {get}
}

public extension CameraPipelineServiceLegacy where PipelineProcessor == Void {
    
    var processor: Void {
        ()
    }
    
    func updateSelection(filter: (any FilterModel)?)  {
    }
}



public extension CameraPipelineServiceLegacy where PipelineProcessor: CameraProccessor {
    func updateSelection(filter: (any FilterModel)?)  {
        processor.updateSelection(filter: filter)
    }
}

public extension CameraPipelineServiceLegacy where PipelineInput: CameraInput {
    func toggleCamera() async  -> Bool {
        return await input.toggleCamera()
    }
}

public extension CameraPipelineServiceLegacy {
    
    var cameraModePublisher: CurrentValueSubject<CameraMode, Never> {
        return recordOutput.cameraModePublisher
    }
    
    func performAction( action: CameraAction) async throws -> Bool {
        return try await recordOutput.performAction(action:action)
    }
    
    func attachDisplay(_ target: some CameraDisplayTarget) throws {
        throw DisplayAttachError.invalidInput
    }
    
}
