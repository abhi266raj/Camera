//
//  CameraContentRecordingProxyService.swift
//  PlatformKit
//
//  Created by Abhiraj on 10/12/25.
//


import Foundation
import Combine
import AVFoundation
import CoreKit
import PlatformKit_api

public final class CameraContentRecordingProxyService: CameraDiskOutputService {
    public var availableOutput: [AVCaptureOutput] {
        return actualService.availableOutput
    }
    
    private let actualService: CameraDiskOutputService
    public var cameraModePublisher: CurrentValueSubject<CameraMode, Never> {
        actualService.cameraModePublisher
    }

    public init(actualService: CameraDiskOutputService) {
        self.actualService = actualService
    }
    
    public convenience init(supportedCameraTask: SupportedCameraTask) {
        switch supportedCameraTask {
        case .capturePhoto:
            break
        case .none:
            self.init(actualService: PreviewOnlyService())
            return
        case .recordVideo:
            break
        }
        
        self.init(actualService: PreviewOnlyService())
    }

    public func performAction(action: CameraAction) async throws -> Bool {
        try await actualService.performAction(action: action)
    }
    
}
