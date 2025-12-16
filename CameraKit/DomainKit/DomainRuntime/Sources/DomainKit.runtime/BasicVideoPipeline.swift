//
//  BasicCameraPipeline.swift
//  CameraKit
//
//  Created by Abhiraj on 08/10/23.
//

import AVFoundation
import UIKit
import CoreKit
import PlatformKit_runtime
import DomainApi
import PlatformKit_api

/// Basic Camera Pipeline Use UIView and record on camera
class BasicVideoPipeline:  CameraSubSystem, @unchecked Sendable {
   
 
    public let displayCoordinator: any CameraDisplayCoordinator
    private let captureSession: AVCaptureSession
    //public let output: CameraVideoOutputImp
    public let input: CameraInputImp
    let fileOutput = AVCaptureMovieFileOutput()
    var videoRecordingConfig =  VideoRecordingConfig()
    public lazy var recordOutput: CameraRecordingCameraService = CameraRecordingCameraService(videoCaptureOutput: fileOutput)
    
    public init(platformFactory: PlatformFactory) {
        let session = AVCaptureSession()
        self.captureSession = session
        // recordOutput = CameraRecordingCameraService(videoCaptureOutput: fileOutput)
        self.input = CameraInputImp()
        displayCoordinator = platformFactory.makeVideoLayerDisplayCoordinator(avcaptureSession: session)
    }

    @CameraInputSessionActor
    public func setup() async {
                let _  = setupInputAndOutput()
                input.session = captureSession
                await input.startRunning()
    }
    
    @MainActor
    public func attachDisplay(_ target: some CameraDisplayTarget) throws {
        Task {
            await try displayCoordinator.attach(target)
        }
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
        
        if captureSession.canAddOutput(fileOutput) {
            captureSession.addOutput(fileOutput)
        }else {
            return false
        }
       
        return true
    }
    
}
