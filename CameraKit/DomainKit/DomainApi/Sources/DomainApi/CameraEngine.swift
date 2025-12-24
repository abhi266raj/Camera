//
//  CameraPipeline.swift
//  CameraKit
//
//  Created by Abhiraj on 16/10/23.
//

import CoreKit

public protocol Specs {
    var capabilty: EngineOption.Capabilty {get}
    var allConfig: [EngineOption.Config] {get}
    var availableProfile: [CameraProfile:EngineOption.Config] {get}
}

public enum EngineAction {
    case start
    case pause
    case setup
    case toggle
    case takePicture
    case startRecording
    case stopRecording
}

public protocol CameraEngine: Sendable {
    var activeConfig: EngineOption.Config {get}
    func perform(_ action: EngineAction) async throws
    func attachDisplay(_ target: some CameraDisplayTarget) async throws
    var cameraMode: AsyncSequence<CameraMode, Never> { get }
}







 
