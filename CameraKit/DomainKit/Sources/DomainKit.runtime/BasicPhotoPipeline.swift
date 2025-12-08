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

/// Basic Camera Pipeline Use UIView and record on camera
public class BasicPhotoPipeline: NSObject, CameraPipelineService, @unchecked Sendable {
    
    public typealias InputType = CameraInputImp
    typealias ProcessorType = EmptyCameraProcessor
    typealias OutputType = CameraPhotoOutputImp
    
    private let captureSession: AVCaptureSession
    public let output: CameraPhotoOutputImp
    public let input: InputType
    let photoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
    public var processor = EmptyCameraProcessor()
    
    @MainActor
    public init(cameraOutputAction: CameraAction) {
        let session = AVCaptureSession()
        self.captureSession = session
        self.output = CameraPhotoOutputImp(session: session, photoOutput: photoOutput)
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
        
        return true
    }
}
