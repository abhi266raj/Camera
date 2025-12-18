//
//  BasicPhotoPipeline.swift
//  CameraKit
//
//  Created by Abhiraj on 08/10/23.
//

import Foundation
import AVFoundation
import CoreMedia
import CoreKit
import PlatformApi
import DomainApi

/// Basic Camera Pipeline Use UIView and record on camera
class BasicMetalPipeline: NSObject, CameraSubSystem, @unchecked Sendable, CameraInputSubSystem, CameraEffectSubSystem, CameraRecordingSubSystem {
            
    private let captureSession: AVCaptureSession
    public let recordOutput: CameraDiskOutputService

    private(set) var input: CameraInput
    let bufferOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    let audioOutput: AVCaptureAudioDataOutput = AVCaptureAudioDataOutput()
    let videoQueue = DispatchQueue(label: "videoQueue")
    let audioQueue = DispatchQueue(label: "audioQueue")
    let processor: CameraProccessor
    public  let displayCoordinator: any CameraDisplayCoordinator
    private let metalView: PreviewMetalTarget
    
    @MainActor
    // Metal view need main actor. Shoule be added via somewhere else
    public init(platformFactory: PlatformFactory, filterSelectionDelegateProxy: FilterSelectionDelegateProxy) {
        let session = AVCaptureSession()
        self.captureSession = session
        recordOutput = platformFactory.makeSampleBufferOutputService()
        let metalView = platformFactory.makePreviewMetalTarget()
        displayCoordinator = platformFactory.makeMetalDisplayCoordinator(metalView: metalView)
        self.metalView = metalView
        self.input = platformFactory.makeCameraInput()
        self.processor = platformFactory.makeEffectProcessor()
        filterSelectionDelegateProxy.target =  processor
        super.init()
        bufferOutput.setSampleBufferDelegate(self, queue: videoQueue)
        audioOutput.setSampleBufferDelegate(self, queue: audioQueue)
        metalView.renderingDelegate = self
    }
    
    //@CameraInputSessionActor
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
            // Image render it than uTask { [sampleBuffer] in
            
                 metalView.sampleBuffer = sampleBuffer
            //}
            
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
    
//    func updateSelection(filter: (any FilterModel)?)  {
//        processor.updateSelection(filter: filter)
//    }
}


