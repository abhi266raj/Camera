//
//  MultiCamPipeline.swift
//  DomainKit
//
//  Created by Abhiraj on 09/12/25.
//

import Foundation
import AVFoundation
import UIKit
import Photos
import CoreKit
import PlatformKit_runtime
import DomainKit_api
import PlatformKit_api

/// Multi Camera Pipeline Use UIView and record on camera
class MultiCamPipeline: NSObject, CameraSubSystem, @unchecked Sendable {
    
    public let input: CameraInputImp
    public let recordOutput: CameraContentRecordingProxyService
    public let displayCoordinator: any CameraDisplayCoordinator
    private let captureSession: AVCaptureMultiCamSession
    
    public init(platformFactory: PlatformFactory) {
        let session = AVCaptureMultiCamSession()
        self.captureSession = session
        recordOutput = CameraContentRecordingProxyService()
        displayCoordinator = platformFactory.makeMultiCameraDisplayCoordinator(avcaptureSession: session)
        self.input = CameraInputImp()
        super.init()
        
        
    }
    
    @CameraInputSessionActor
    public func setup() async {
       // Task{ @CameraInputSessionActor  in
            await self.setupInput()
        //}
    }
    
    @CameraInputSessionActor
    private func setupInput() async {
        let _  = self.setupInputAndOutput()
        input.session = captureSession
        await input.startRunning()
        
    }
    
    var ports:[AVCaptureInput.Port] = []
    
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
        
        guard backCamera.ports.count > 0, frontCamera.ports.count > 0 else {
            return false
        }
        ports = [backCamera.ports[0], frontCamera.ports[0]]
        return true
    }
    
    public func toggleCamera() async -> Bool {
        ports.swapAt(0, 1)
        await updatePort(front: ports[0], back: ports[1])
        return true
    }
    
    @MainActor
    public func updatePort(front:AVCaptureInput.Port, back: AVCaptureInput.Port) {
        captureSession.beginConfiguration()
//        let frontConnection = AVCaptureConnection(inputPort: front, videoPreviewLayer: displayCoordinator.firstLayer)
//        let backConnection = AVCaptureConnection(inputPort: back, videoPreviewLayer: displayCoordinator.secondLayer)
//        captureSession.removeConnection(displayCoordinator.firstLayer.connection!)
//        captureSession.removeConnection(displayCoordinator.secondLayer.connection!)
//        captureSession.addConnection(frontConnection)
//        captureSession.addConnection(backConnection)
        captureSession.commitConfiguration()
    }
    
    
    @MainActor
    public func attachDisplay(_ target: some CameraDisplayTarget) throws {
        Task {
            await try displayCoordinator.attach(target)
        }
    }
    
}

