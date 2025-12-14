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

public protocol CameraPipelineServiceLegacy: CameraEngine {
    associatedtype PipelineInput: CameraInput
    associatedtype PipelineDisplayCoordinator: CameraDisplayCoordinator
    associatedtype PipelineRecordingOutput: CameraDiskOutputService
    associatedtype PipelineProcessor: CameraProccessor
    
    var input: PipelineInput {get}
    var displayCoordinator: PipelineDisplayCoordinator {get}
    var recordOutput: PipelineRecordingOutput {get }
    var processor: PipelineProcessor {get}
}


public extension CameraPipelineServiceLegacy {
    
    func updateSelection(filter: (any FilterModel)?)  {
        processor.updateSelection(filter: filter)
    }
    
    func toggleCamera() async  -> Bool {
        return await input.toggleCamera()
    }

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
