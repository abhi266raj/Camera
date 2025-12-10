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

public class CameraRecordingCameraService: CameraContentRecordingService {
    public var cameraModePublisher = CurrentValueSubject<CameraMode, Never>(.preview)
    let videoCaptureOutput:AVCaptureMovieFileOutput
    var fileRecorder: BasicFileRecorder?
    public let supportedOutput: CameraAction = [.startRecord, .stopRecord]
    
    public init() {
    }
    
    public func performAction(action: CameraAction) async throws -> Bool {
        throw CameraAction.ActionError.invalidInput
    }
}
