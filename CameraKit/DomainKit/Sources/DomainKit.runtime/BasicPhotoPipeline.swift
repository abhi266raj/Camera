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

/// Basic Camera Pipeline Use UIView and record on camera
public class BasicPhotoPipeline: NSObject, CameraPipelineService, @unchecked Sendable {
    
    private let captureSession: AVCaptureSession
    public let output: CameraPhotoOutputImp
    public let input: CameraSessionHandlerImp
    let photoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
    public var processor = EmptyCameraProcessor()
    var imageCaptureConfig: ImageCaptureConfig {
        return output.recordingService.imageCaptureConfig
    }
    @MainActor
    public init(cameraOutputAction: CameraAction) {
        let session = AVCaptureSession()
        self.captureSession = session
        self.output = CameraPhotoOutputImp(session: session, photoOutput: photoOutput)
        self.input = CameraSessionHandlerImp(session: session)
    }
    
    public func setup() {
        Task{ @CameraInputSessionActor  in
            await self.setupInput()
        }
    }
    
    @CameraInputSessionActor
    private func setupInput() async {
        await self.setupInputAndOutput()
        await input.start()
    }
    
     public func toggleCamera() async -> Bool {
         await input.toggleCamera()
         let config = CameraInputConfig(photoResolution: imageCaptureConfig.resolution)
         return await input.update(config: config)
    }
    
    @CameraInputSessionActor
    private func setupInputAndOutput() async -> Bool {
        let config = CameraInputConfig(photoResolution: imageCaptureConfig.resolution)
        return await input.setup(input: [], output: [photoOutput], config: config)
    }
    
    func configureCamera() {
        
    }
    
}
