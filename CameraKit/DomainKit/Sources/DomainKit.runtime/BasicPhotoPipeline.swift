//
//  BasicPhotoPipeline.swift
//  CameraKit
//
//  Created by Abhiraj on 08/10/23.
//

import Foundation
import AVFoundation
import UIKit
import Photos
import CoreKit
import PlatformKit_runtime
import DomainKit_api
import PlatformKit_api
import Combine

/// Basic Camera Pipeline Use UIView and record on camera
public class BasicPhotoPipeline: NSObject, @unchecked Sendable, CameraService {
    
    private let captureSession: AVCaptureSession
    public let output: CameraPhotoOutputImp
    public let sessionManager: CameraSessionHandlerImp
    let photoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
    private let processor = EmptyCameraProcessor()
    var imageCaptureConfig: ImageCaptureConfig {
        return output.recordingService.imageCaptureConfig
    }
    @MainActor
    public init(cameraOutputAction: CameraAction) {
        let session = AVCaptureSession()
        self.captureSession = session
        self.output = CameraPhotoOutputImp(session: session, photoOutput: photoOutput)
        self.sessionManager = CameraSessionHandlerImp(session: session)
    }
    
    public func setup() {
        Task{ @CameraInputSessionActor  in
            let config = CameraInputConfig(photoResolution: imageCaptureConfig.resolution)
            return await sessionManager.setup(input: [], output: [photoOutput], config: config)
            await sessionManager.start()
        }
    }
    
    @CameraInputSessionActor
     public func toggleCamera() async -> Bool {
         let config = CameraInputConfig(photoResolution: imageCaptureConfig.resolution)
         return await sessionManager.toggle(config: config)
    }
    
    func configureCamera() {
        
    }
    
}

public extension BasicPhotoPipeline {
    func getOutputView() -> CameraContentPreviewService {
        return output.previewService
    }
    
    func updateSelection(filter: (any FilterModel)?)  {
        processor.updateSelection(filter: filter)
    }
    
    var cameraModePublisher: CurrentValueSubject<CameraMode, Never> {
        return output.recordingService.cameraModePublisher
    }
    
    func performAction( action: CameraAction) async throws -> Bool {
        return try await output.recordingService.performAction(action:action)
    }
    
}
