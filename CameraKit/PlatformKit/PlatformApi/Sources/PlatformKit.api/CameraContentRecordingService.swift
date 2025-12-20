//
//  CameraDiskOutputService.swift
//  CameraKit
//
//  Created by Abhiraj on 05/12/25.
//

import Combine
import CoreKit
import Foundation
import AVFoundation


public protocol CameraDiskOutputService {
    var cameraModePublisher: CurrentValueSubject<CameraMode, Never> { get }
    func performAction( action: CameraAction) async throws -> Bool
}

public protocol AVCaptureDiskOutputService: CameraDiskOutputService {
    var availableOutput: [AVCaptureOutput] {get}
}

public protocol SampleBufferDiskOutputService: CameraDiskOutputService {
    func appendSampleBuffer(_ sampleBuffer: CMSampleBuffer)
}

public protocol VideoOutput {
    func startRecord() async
    func stopRecord() async
    var videoSaver: VideoSaver {get}
    var videoRecorder: VideoRecorder? {get}
}

public protocol VideoSaver {
    func save(outputFileURL: URL, error: Error?)
}

public protocol VideoRecorder {
    func appendSampleBuffer(_ sampleBuffer: CMSampleBuffer)
    func stopRecording(completion: @escaping (URL) -> Void)
}
