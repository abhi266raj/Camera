//
//  SampleBufferCameraRecorderService.swift
//  CameraKit
//
//  Created by Abhiraj on 05/12/25.
//


import Foundation
import AVFoundation
import UIKit
import Photos
import Combine
import CoreKit

public class SampleBufferCameraRecorderService: CameraContentRecordingService {
    public var cameraModePublisher = CurrentValueSubject<CameraMode, Never>(.preview)
    
    let videoOutput: VideoOutput
    
    public let supportedOutput: CameraAction = [.startRecord, .stopRecord]
    
    public init(videoOutput: VideoOutput) {
        self.videoOutput = videoOutput
    }
    
    public func performAction(action: CameraAction) async throws -> Bool {
        guard self.supportedOutput.contains(action) else {
            throw CameraAction.ActionError.invalidInput
        }
        
        if action == .startRecord {
            cameraModePublisher.send(.initiatingCapture)
           await videoOutput.startRecord()
            cameraModePublisher.send(.capture(.video))
            return true
        }else if action == .stopRecord {
            cameraModePublisher.send(.initiatingCapture)
            await videoOutput.stopRecord()
            cameraModePublisher.send(.preview)
            return true
        }
        throw CameraAction.ActionError.unsupported
    }
    
    public func appendSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        videoOutput.videoRecorder?.appendSampleBuffer(sampleBuffer)
    }
}
