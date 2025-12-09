//
//  BasicPhotoPipeline 2.swift
//  DomainKit
//
//  Created by Abhiraj on 09/12/25.
//


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

/// Multi Camera Pipeline Use UIView and record on camera
public class MultiCamPipeline: NSObject, CameraPipelineServiceNew, @unchecked Sendable {
    
    public let input: CameraInputImp
    public let previewOutput: MultiCameraPreviewView
    public let recordOutput: CameraPhotoCameraService
    public let processor: EmptyCameraProcessor = EmptyCameraProcessor()
    
    private let captureSession: AVCaptureMultiCamSession
    private let photoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
    
    @MainActor
    public init(cameraOutputAction: CameraAction) {
        let session = AVCaptureMultiCamSession()
        self.captureSession = session
        previewOutput = MultiCameraPreviewView(session: session)
        recordOutput = CameraPhotoCameraService(photoOutput: photoOutput)
        self.input = CameraInputImp()
    }
    
    public func setup() {
        Task{ @CameraInputSessionActor  in
            await self.setupInput()
        }
    }
    
    @CameraInputSessionActor
    private func setupInput() async {
        let _  = self.setupInputAndOutput()
        input.session = captureSession
        input.startRunning()
        
    }
    
    var ports:[[AVCaptureInput.Port]] = []
    
    private func setupInputAndOutput() -> Bool {
        guard let frontCamera = input.frontCamera else {return false}
        guard let backCamera = input.backCamera else {return false}
        guard let audioDevice =  input.audioDevice else {return false}
        captureSession.beginConfiguration()
        defer {
            captureSession.commitConfiguration()
        }
        
        if captureSession.canAddInput(backCamera) {
            captureSession.addInput(backCamera)
        }else{
            return false
        }
        
        if captureSession.canAddInput(frontCamera) {
            captureSession.addInput(frontCamera)
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
        
        ports = [backCamera.ports, frontCamera.ports]
        return true
    }
    
    public func toggleCamera() async -> Bool {
        ports.swapAt(0, 1)
        await previewOutput.updatePort(front: ports[0], back: ports[1])
        return true
    }
}

