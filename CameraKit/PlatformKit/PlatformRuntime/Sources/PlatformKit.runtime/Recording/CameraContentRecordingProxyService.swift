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
import PlatformApi

//final class CameraContentRecordingProxyService: AVCaptureDiskOutputService {
//    public var availableOutput: [AVCaptureOutput] {
//        return actualService.availableOutput
//    }
//    
//    private let actualService: AVCaptureDiskOutputService
//    public var cameraModePublisher: CurrentValueSubject<CameraMode, Never> {
//        actualService.cameraModePublisher
//    }
//
//    public init(actualService: AVCaptureDiskOutputService) {
//        self.actualService = actualService
//    }
//    
//    public convenience init() {        
//        self.init(actualService: PreviewOnlyService())
//    }
//
//    public func performAction(action: CameraAction) async throws -> Bool {
//        try await actualService.performAction(action: action)
//    }
//    
//}
