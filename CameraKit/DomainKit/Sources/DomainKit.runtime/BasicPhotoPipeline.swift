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
    public let input: ConfigurableCameraInputImp
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
        self.input = ConfigurableCameraInputImp()
    }
    
    public func setup() {
        Task{ @CameraInputSessionActor  in
            await self.setupInput()
        }
    }
    
    @CameraInputSessionActor
    private func setupInput() async {
        let r1  = self.setupInputAndOutput()
        input.session = captureSession
        let config = CameraInputConfig(dimension: imageCaptureConfig.resolution.maxDimension(), position: input.selectedPosition)
        let r2 = input.configureDeviceFor(config: CameraInputConfig(dimension: imageCaptureConfig.resolution.maxDimension(), position: input.selectedPosition))
        
        print(r1, r2)
        if r1 && r2 {
            input.startRunning()
        }
        
    }
    
     public func toggleCamera() async -> Bool {
         await input.toggleCamera()
         let config = await CameraInputConfig(dimension: imageCaptureConfig.resolution.maxDimension(), position: input.selectedPosition)
         let value = await  input.configureDeviceFor(config: CameraInputConfig(dimension: imageCaptureConfig.resolution.maxDimension(), position: input.selectedPosition))
         if value == false {
             await input.stopRunning()
         }
         return true
        
    }
    
    @CameraInputSessionActor
    private func setupInputAndOutput() -> Bool {
        guard let videoDevice =  input.videoDevice else {return false}
        guard let audioDevice =  input.audioDevice else {return false}
        captureSession.beginConfiguration()
        
        defer {
            captureSession.commitConfiguration()
        }
        
      

        if captureSession.canAddInput(videoDevice) {
            captureSession.addInput(videoDevice)
        }else{
            return false
        }
        
        if captureSession.canAddInput(audioDevice) {
            captureSession.addInput(audioDevice)
        }else{
            return false
        }
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }else {
            return false
        }
        
        let formats = videoDevice.device.formats
        let dimensions = imageCaptureConfig.resolution.maxDimension()
        let matched = formats.first {
            $0.supportedMaxPhotoDimensions.contains { $0.width == dimensions.width &&
                                                     $0.height == dimensions.height }
        }

        guard let format = matched else { return false }

        do {
            try videoDevice.device.lockForConfiguration()
            videoDevice.device.activeFormat = format
            videoDevice.device.unlockForConfiguration()
        } catch {
            return false
        }
        
        return true
    }
    
    func configureCamera() {
        
    }
    
}
