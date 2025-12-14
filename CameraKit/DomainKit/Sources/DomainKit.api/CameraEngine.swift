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


public protocol Specs {
    var capabilty: EngineOption.Capabilty {get}
    var allConfig: [EngineOption.Config] {get}
    var availableProfile: [CameraProfile:EngineOption.Config] {get}
}

public enum EngineAction {
    case setup
    case toggle
    case updateFilter(FilterModel)
    case takePicture
    case startRecording
    case stopRecording
}

public protocol CameraEngineNew {
    var activeConfig: EngineOption.Config {get}
    func perform(_ action: EngineAction) async throws
    @MainActor
    func attachDisplay(_ target: some CameraDisplayTarget) throws
    var cameraModePublisher: CurrentValueSubject<CameraMode, Never> { get }
}







 
