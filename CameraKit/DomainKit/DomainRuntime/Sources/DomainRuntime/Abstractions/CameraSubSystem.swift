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

protocol CameraInputSubSystem {
    var input:CameraInput {get}
}

protocol CameraEffectSubSystem {
    var processor: CameraProccessor {get}
}

protocol CameraRecordingSubSystem {
    var recordOutput: CameraDiskOutputService {get}
}


protocol CameraSubSystem {
  //   associatedtype DiskOutput: CameraDiskOutputService
   //  associatedtype Processor =  Void
    
    var displayCoordinator: any CameraDisplayCoordinator {get}
    //var recordOutput: DiskOutput {get }
    //var processor: Processor {get}
    
    func updateSelection(filter: (any FilterModel)?)
    func toggleCamera() async  -> Bool
    var cameraModePublisher: CurrentValueSubject<CameraMode, Never> { get }
    func performAction( action: CameraAction) async throws -> Bool
    func setup() async
    @MainActor
    func attachDisplay(_ target: some CameraDisplayTarget) throws
}


extension CameraSubSystem  {
        
    func updateSelection(filter: (any FilterModel)?)  {
    }
}

extension CameraInputSubSystem  {
    func toggleCamera() async  -> Bool {
        return await input.toggleCamera()
    }
}

extension CameraSubSystem {
    
    func attachDisplay(_ target: some CameraDisplayTarget) throws {
        throw DisplayAttachError.invalidInput
    }
    
}

extension CameraRecordingSubSystem {
    
    var cameraModePublisher: CurrentValueSubject<CameraMode, Never> {
        return recordOutput.cameraModePublisher
    }
    
    func performAction( action: CameraAction) async throws -> Bool {
        return try await recordOutput.performAction(action:action)
    }
    
}

