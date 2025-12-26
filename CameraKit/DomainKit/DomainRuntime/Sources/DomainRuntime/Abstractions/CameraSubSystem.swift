//
//  CameraPipelineServiceLegacy.swift
//  DomainKit
//
//  Created by Abhiraj on 14/12/25.
//

import CoreKit

protocol CameraSubSystem: Sendable {
    func toggleCamera() async  -> Bool
    var cameraModePublisher: AsyncSequence<CameraMode, Never>  { get }
    func performAction( action: CameraAction) async throws -> Bool
    func setup() async
    func start() async
    func stop() async
    func attachDisplay(_ target: some CameraDisplayTarget) async throws
}
