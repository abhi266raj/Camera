//
//  BasicPhotoPipeline.swift
//  CameraKit
//
//  Created by Abhiraj on 08/10/23.
//

import Foundation
@preconcurrency import AVFoundation
import CoreKit
import DomainApi
import PlatformApi
internal import Combine
internal import Synchronization

/// Basic Camera Pipeline Use UIView and record on camera
final class BasicPhotoPipeline: NSObject, CameraSubSystem, Sendable {
   
    public  let displayCoordinator: any CameraDisplayCoordinator
    
    public let recordOutput: AVCaptureDiskOutputService
    
    private let captureSession: AVCaptureSession
    public let sessionManager: CameraSessionService
    let photoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
    let imageCaptureConfig: ImageCaptureConfig  = ImageCaptureConfig()
    let inputDevice: CameraInput
    let sessionState: SessionState = SessionState()
    let sessionConfig: SessionConfig = SessionConfig()
   
    
    public init(platformFactory: PlatformFactory) {
        let session = AVCaptureSession()
        self.captureSession = session
        displayCoordinator = platformFactory.makeVideoLayerDisplayCoordinator(avcaptureSession: session)
        recordOutput = platformFactory.makePhotoOutputService(imageCaptureConfig: imageCaptureConfig)
        inputDevice = platformFactory.makeCameraInput()
        sessionManager = platformFactory.makeSessionService()
        if let videoDevice = inputDevice.backCamera {
            sessionState.selectedVideoDevice = [videoDevice]
        }
    }
    
    public func setup() async {
        imageCaptureConfig.resolution.maxDimension()
        sessionConfig.videoResolution = CameraInputConfig(photoResolution: imageCaptureConfig.resolution).dimensions
        sessionConfig.videoDevice = sessionState.selectedVideoDevice
        sessionConfig.contentOutput = recordOutput.availableOutput
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
    
    @MainActor
    public func attachDisplay(_ target: some CameraDisplayTarget) throws {
        Task {
            await try displayCoordinator.attach(target)
        }
    }
    
}

extension BasicPhotoPipeline {
    
    var cameraModePublisher: AsyncSequence<CameraMode, Never> {
        return recordOutput.cameraModePublisher.values
    }
    
    func performAction( action: CameraAction) async throws -> Bool {
        return try await recordOutput.performAction(action:action)
    }
    
    
    func toggledDevice() -> [AVCaptureDeviceInput] {
        if sessionState.selectedVideoDevice.first?.device.uniqueID == inputDevice.frontCamera?.device.uniqueID {
            return [inputDevice.backCamera].compactMap { $0 }
        }else {
            return  [inputDevice.frontCamera].compactMap { $0 }
        }
    }
    
}
