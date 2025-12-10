//
//  PreviewOnlyService.swift
//  PlatformKit
//
//  Created by Abhiraj on 10/12/25.
//


import Foundation
import Combine
import AVFoundation
import CoreKit
import PlatformKit_api

public class PreviewOnlyService: CameraContentRecordingService {
    public var cameraModePublisher = CurrentValueSubject<CameraMode, Never>(.preview)
    public let supportedOutput: CameraAction = []
    
    public init() {
    }
    
    public func performAction(action: CameraAction) async throws -> Bool {
        throw CameraAction.ActionError.invalidInput
    }
}
