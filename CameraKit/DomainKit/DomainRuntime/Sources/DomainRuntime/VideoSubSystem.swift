//
//  VideoSubSystem.swift
//  CameraKit
//
//  Created by Abhiraj on 25/12/25.
//

@preconcurrency internal import AVFoundation
import CoreKit
import DomainApi
import PlatformApi
internal import Synchronization

final class VideoSubSystem: NSObject, CameraSubSystem, Sendable {
   
    public  let displayCoordinator: any CameraSessionDisplayCoordinator
    
    public let recordOutput: BasicVideoRecordWorker
    
    private let captureSession: AVCaptureSession
    public let sessionManager: CameraSessionService
    let videoOutput: AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
    let inputDevice: CameraInput
    let sessionState: SessionState = SessionState()
    let sessionConfig: SessionConfig = SessionConfig()
    let continuation: Mutex<AsyncStream<CameraMode>.Continuation?> = Mutex(nil)
    private let supportedOutput: CameraAction = [.startRecord, .stopRecord]
   
    
    public init(platformFactory: PlatformFactory) {
        let session = AVCaptureSession()
        self.captureSession = session
        displayCoordinator = platformFactory.makeVideoLayerDisplayCoordinator()
        recordOutput = platformFactory.makeBasicVideoRecordWorker()
        inputDevice = platformFactory.makeCameraInput()
        sessionManager = platformFactory.makeSessionService()
        if let videoDevice = inputDevice.backCamera {
            sessionState.selectedVideoDevice = [videoDevice]
        }
    }
    
    public func setup() async {
        sessionConfig.videoDevice = sessionState.selectedVideoDevice
        sessionConfig.contentOutput = [videoOutput]
        if let _ = await try? sessionManager.apply(sessionConfig, session: captureSession) {
            await captureSession.startRunning()
        }
        
    }
    
    public func start() async {
        await captureSession.startRunning()
    }
    
    public func stop() async {
        await captureSession.stopRunning()
    }
    
     public func toggleCamera() async -> Bool {
         let device = toggledDevice()
         await sessionState.update(device)
         sessionConfig.videoDevice = sessionState.selectedVideoDevice
         await try? sessionManager.apply(sessionConfig, session: captureSession)
         return true
    }
    
    public func attachDisplay(_ target: some CameraDisplayTarget) async throws {
        displayCoordinator.updateSession(session: captureSession)
        await try displayCoordinator.attach(target)
    }
    
}

extension VideoSubSystem {
    
    var cameraModePublisher: AsyncSequence<CameraMode, Never> {
        let value = AsyncStream<CameraMode>.make()
        continuation.withLock { $0 = value.1}
        return value.0
    }
    
    func performAction( action: CameraAction) async throws -> Bool {
        
        guard self.supportedOutput.contains(action) else {
            throw CameraAction.ActionError.invalidInput
        }
        if action == .startRecord {
            continuation.withLock { $0?.yield(.initiatingCapture)}
            let stream = await recordOutput.startRecording(videoOutput, url: nil)
            continuation.withLock { $0?.yield(.capture(.video))}
            Task.immediate {
                for try await result in stream {
                    try await recordOutput.saveVideoToLibrary(result)
                }
            }
            return true
        }else if action == .stopRecord {
            continuation.withLock { $0?.yield(.initiatingCapture)}
            defer {
                continuation.withLock { $0?.yield(.preview)}
            }
            try recordOutput.stopRecording(output: videoOutput)
            return true
        }
            throw CameraAction.ActionError.unsupported
        return true
    }
    
    
    private func toggledDevice() -> [AVCaptureDeviceInput] {
        if sessionState.selectedVideoDevice.first?.device.uniqueID == inputDevice.frontCamera?.device.uniqueID {
            return [inputDevice.backCamera].compactMap { $0 }
        }else {
            return  [inputDevice.frontCamera].compactMap { $0 }
        }
    }
    
}
