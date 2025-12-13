//
//  CameraPipeline.swift
//  CameraKit
//
//  Created by Abhiraj on 16/10/23.
//

import Foundation
import Observation
import Combine
import CoreKit
import PlatformKit_api

public protocol CameraService {
    //associatedtype CameraDisplayTarget
    func getOutputView() -> CameraDisplayOutput?
    func updateSelection(filter: (any FilterModel)?)
    func toggleCamera() async  -> Bool
    var cameraModePublisher: CurrentValueSubject<CameraMode, Never> { get }
    func performAction( action: CameraAction) async throws -> Bool
    func setup() async
    @MainActor
    func attachDisplay(_ target: some CameraDisplayTarget) throws
}

//public extension CameraService {
//    @MainActor
//    func attachDisplay(_ target: some CameraDisplayTarget) throws {
//        throw DisplayAttachError.invalidInput
//    }
//}

public protocol CameraPipelineService: CameraService {
    associatedtype PipelineInput: CameraInput
    associatedtype PipelineOutput: CameraOutputService
    associatedtype PipelineProcessor: CameraProccessor
    
    var input: PipelineInput {get}
    var output: PipelineOutput {get}
    var processor: PipelineProcessor {get}    
}


public protocol CameraPipelineServiceNew: CameraService {
    associatedtype PipelineInput: CameraInput
    associatedtype PipelineDisplayCoordinator: CameraDisplayCoordinator
    associatedtype PipelineRecordingOutput: CameraDiskOutputService
    associatedtype PipelineProcessor: CameraProccessor
    
    var input: PipelineInput {get}
    var displayCoordinator: PipelineDisplayCoordinator {get}
    var recordOutput: PipelineRecordingOutput {get }
    var processor: PipelineProcessor {get}
}

public extension CameraPipelineService {
    func getOutputView() -> CameraDisplayOutput? {
        return output.previewService
    }
    
    func updateSelection(filter: (any FilterModel)?)  {
        processor.updateSelection(filter: filter)
    }
    
    func toggleCamera() async  -> Bool {
        return await input.toggleCamera()
    }
    
    var cameraModePublisher: CurrentValueSubject<CameraMode, Never> {
        return output.recordingService.cameraModePublisher
    }
    
    func performAction( action: CameraAction) async throws -> Bool {
        return try await output.recordingService.performAction(action:action)
    }
    
    func attachDisplay(_ target: some CameraDisplayTarget) throws {
        throw DisplayAttachError.invalidInput
    }
    
}

public extension CameraPipelineServiceNew {
    
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
