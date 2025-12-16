//
//  CameraPipelineServiceLegacy.swift
//  DomainKit
//
//  Created by Abhiraj on 14/12/25.
//

import CoreKit
import PlatformKit_api
import DomainApi
import Combine
import CoreMedia
import PlatformKit_runtime

public protocol CameraSubSystem {
    associatedtype Input
    associatedtype DiskOutput: CameraDiskOutputService
    associatedtype Processor =  Void
    
    var input: Input {get}
    var displayCoordinator: any CameraDisplayCoordinator {get}
    var recordOutput: DiskOutput {get }
    var processor: Processor {get}
    
    func updateSelection(filter: (any FilterModel)?)
    func toggleCamera() async  -> Bool
    var cameraModePublisher: CurrentValueSubject<CameraMode, Never> { get }
    func performAction( action: CameraAction) async throws -> Bool
    func setup() async
    @MainActor
    func attachDisplay(_ target: some CameraDisplayTarget) throws
}


public extension CameraSubSystem where Processor == Void {
    
    var processor: Void {
        ()
    }
    
    func updateSelection(filter: (any FilterModel)?)  {
    }
}



public extension CameraSubSystem where Processor: CameraProccessor {
    func updateSelection(filter: (any FilterModel)?)  {
        processor.updateSelection(filter: filter)
    }
}

public extension CameraSubSystem where Input: CameraInput {
    func toggleCamera() async  -> Bool {
        return await input.toggleCamera()
    }
}

public extension CameraSubSystem {
    
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

