//
//  PreviewOnlyService.swift
//  PlatformKit
//
//  Created by Abhiraj on 10/12/25.
//


import Foundation
import Combine
@preconcurrency import AVFoundation
import CoreKit
import PlatformApi

class PreviewOnlyService: AVCaptureDiskOutputService, @unchecked Sendable {
    public let cameraModePublisher = CurrentValueSubject<CameraMode, Never>(.preview)
    public let supportedOutput: CameraAction = []
    
    public var availableOutput: [AVCaptureOutput] {
        return []
    }
    
    public init() {
    }
    
    public func performAction(action: CameraAction) async throws -> Bool {
        throw CameraAction.ActionError.invalidInput
    }
}
