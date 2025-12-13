//
//  CameraRecordingCameraService.swift
//  CameraKit
//
//  Created by Abhiraj on 05/12/25.
//

import Foundation
import Combine
import AVFoundation
import CoreKit
import PlatformKit_api

public class CameraRecordingCameraService: CameraDiskOutputService {
    public var cameraModePublisher = CurrentValueSubject<CameraMode, Never>(.preview)
    let videoCaptureOutput:AVCaptureMovieFileOutput
    var fileRecorder: BasicFileRecorder?
    public let supportedOutput: CameraAction = [.startRecord, .stopRecord]
    
    public init(videoCaptureOutput: AVCaptureMovieFileOutput) {
        self.videoCaptureOutput = videoCaptureOutput
    }
    
    public var availableOutput: [AVCaptureOutput] {
        return [videoCaptureOutput]
    }
    
    public func performAction(action: CameraAction) async throws -> Bool {
        guard self.supportedOutput.contains(action) else {
            throw CameraAction.ActionError.invalidInput
        }
        if action == .startRecord {
            cameraModePublisher.send(.initiatingCapture)
            fileRecorder =  BasicFileRecorder(fileOutput: videoCaptureOutput)
            await fileRecorder?.start(true)
            cameraModePublisher.send(.capture(.video))
            return true
        }else if action == .stopRecord {
            cameraModePublisher.send(.initiatingCapture)
            await fileRecorder?.start(false)
            cameraModePublisher.send(.preview)
            return true
        }
            throw CameraAction.ActionError.unsupported
        }
}
