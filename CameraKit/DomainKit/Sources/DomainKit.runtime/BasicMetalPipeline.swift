//
//  BasicPhotoPipeline.swift
//  CameraKit
//
//  Created by Abhiraj on 08/10/23.
//

import Foundation
import AVFoundation
import Photos
import CoreMedia
import CoreKit
import PlatformKit_runtime
import PlatformKit_api
import DomainKit_api

/// Basic Camera Pipeline Use UIView and record on camera
public class BasicMetalPipeline: NSObject, CameraSubSystem, @unchecked Sendable {
            
    private let captureSession: AVCaptureSession
    public let recordOutput: SampleBufferCameraRecorderService

    public let input: CameraInputImp
    let bufferOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    let audioOutput: AVCaptureAudioDataOutput = AVCaptureAudioDataOutput()
    let videoQueue = DispatchQueue(label: "videoQueue")
    let audioQueue = DispatchQueue(label: "audioQueue")
    public var processor: EffectCameraProcessor = EffectCameraProcessor()
    public  let displayCoordinator: any CameraDisplayCoordinator
    private let metalView: PreviewMetalView
    
    @MainActor
    // Metal view need main actor. Shoule be added via somewhere else
    public init(cameraOutputAction: CameraAction) {
        let session = AVCaptureSession()
        self.captureSession = session
        let videoOutput = VideoOutputImp()
        recordOutput = SampleBufferCameraRecorderService(videoOutput: videoOutput)
        let metalView = PreviewMetalView(frame: .zero)
        displayCoordinator = PlatformFactoryImp().makeMetalDisplayCoordinator(metalView: metalView)
        self.metalView = metalView
        self.input = CameraInputImp()
        super.init() 
        bufferOutput.setSampleBufferDelegate(self, queue: videoQueue)
        audioOutput.setSampleBufferDelegate(self, queue: audioQueue)
        metalView.renderingDelegate = self
    }
    
    @CameraInputSessionActor
    public func setup() async {
            let _  = self.setupInputAndOutput()
            self.input.session = self.captureSession
            await self.input.startRunning()
    }
    
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
        
        if captureSession.canAddOutput(bufferOutput) {
            bufferOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
            captureSession.addOutput(bufferOutput)
        }else {
            return false
        }
        
        if captureSession.canAddOutput(audioOutput) {
            captureSession.addOutput(audioOutput)
        }else {
            return false
        }
        
        return true
    }
    
    @MainActor
    public func attachDisplay(_ target: some CameraDisplayTarget) throws {
        Task {
            await try displayCoordinator.attach(target)
        }
    }
}

extension BasicMetalPipeline: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let sampleBuffer = processor.process(sampleBuffer: sampleBuffer)
        if CMSampleBufferGetImageBuffer(sampleBuffer) != nil {
            // Image render it than use via delegate to record
            self.metalView.sampleBuffer = sampleBuffer
        }else{
            // Audio delegate record it
            self.recordOutput.appendSampleBuffer(sampleBuffer)
        }
      
    }
    
}


extension BasicMetalPipeline: MetalRenderingDelegate {
    public func sampleBufferRendered(_ buffer: CMSampleBuffer) {
        recordOutput.appendSampleBuffer(buffer)
    }
}


