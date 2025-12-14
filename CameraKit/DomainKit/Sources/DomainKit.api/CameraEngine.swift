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

public protocol CameraEngine {
    func updateSelection(filter: (any FilterModel)?)
    func toggleCamera() async  -> Bool
    var cameraModePublisher: CurrentValueSubject<CameraMode, Never> { get }
    func performAction( action: CameraAction) async throws -> Bool
    func setup() async
    @MainActor
    func attachDisplay(_ target: some CameraDisplayTarget) throws
}


