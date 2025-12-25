//
//  CameraPipelineServiceLegacy.swift
//  DomainKit
//
//  Created by Abhiraj on 14/12/25.
//

import CoreKit
import PlatformApi
import DomainApi
internal import Combine
internal import CoreMedia

protocol CameraInputSubSystem {
    var input:CameraInput {get}
}

protocol CameraEffectSubSystem {
    var processor: CameraProccessor {get}
}

protocol CameraRecordingSubSystem {
    var recordOutput: CameraDiskOutputService {get}
}


protocol CameraSubSystem: Sendable {
    func toggleCamera() async  -> Bool
    var cameraModePublisher: AsyncSequence<CameraMode, Never>  { get }
    func performAction( action: CameraAction) async throws -> Bool
    func setup() async
    func start() async
    func stop() async
    func attachDisplay(_ target: some CameraDisplayTarget) async throws
}

extension CameraInputSubSystem  {
    func toggleCamera() async  -> Bool {
        return false
        //return await input.toggleCamera()
    }
}


extension CameraRecordingSubSystem {
    
    var cameraModePublisher: AsyncSequence<CameraMode, Never> {
        return recordOutput.cameraModePublisher.values
    }
    
    func performAction( action: CameraAction) async throws -> Bool {
        return try await recordOutput.performAction(action:action)
    }
    
}

