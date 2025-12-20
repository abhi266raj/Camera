//
//  BasicPhotoPipeline.swift
//  CameraKit
//
//  Created by Abhiraj on 08/10/23.
//

import Foundation
import AVFoundation
internal import CoreMedia
import CoreKit
import PlatformApi
import DomainApi

/// Basic Camera Pipeline Use UIView and record on camera
class BasicMetalPipeline: NSObject, CameraSubSystem, @unchecked Sendable, CameraInputSubSystem, CameraEffectSubSystem, CameraRecordingSubSystem {
            
    private let captureSession: AVCaptureSession
    public var recordOutput: CameraDiskOutputService {
        sampleBufferOutputService
    }
    
    private let sampleBufferOutputService: SampleBufferDiskOutputService

    private(set) var input: CameraInput
    let bufferOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    let audioOutput: AVCaptureAudioDataOutput = AVCaptureAudioDataOutput()
    let videoQueue = DispatchQueue(label: "videoQueue")
    let audioQueue = DispatchQueue(label: "audioQueue")
    let processor: CameraProccessor
    public  let displayCoordinator: any CameraDisplayCoordinator
    private let metalView: PreviewMetalTarget
    private var streamTask : Task<Void, Never>
    
    @MainActor
    // Metal view need main actor. Shoule be added via somewhere else
    public init(platformFactory: PlatformFactory, stream: AsyncStream<FilterModel>) {
        let session = AVCaptureSession()
        self.captureSession = session
        sampleBufferOutputService = platformFactory.makeSampleBufferOutputService()
        let metalView = platformFactory.makePreviewMetalTarget()
        displayCoordinator = platformFactory.makeMetalDisplayCoordinator(metalView: metalView)
        self.metalView = metalView
        self.input = platformFactory.makeCameraInput()
        let effectProcessor = platformFactory.makeEffectProcessor()
        self.processor = effectProcessor
        
        self.streamTask = Task { 
            for await filter in stream {
                effectProcessor.selectedFilter = filter
            }
        }
       
        super.init()
        bufferOutput.setSampleBufferDelegate(self, queue: videoQueue)
        audioOutput.setSampleBufferDelegate(self, queue: audioQueue)
        metalView.renderingDelegate = self
        
    }
    
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
        if CMSampleBufferGetImageBuffer(sampleBuffer) != nil {
            let sampleBuffer = processor.process(sampleBuffer: sampleBuffer)
            metalView.captureOutput?(output, didOutput: sampleBuffer, from: connection)
        }else{
            // Audio delegate record it
            self.sampleBufferOutputService.appendSampleBuffer(sampleBuffer)
        }
      
    }
    
}


extension BasicMetalPipeline: MetalRenderingDelegate {
    public func sampleBufferRendered(_ buffer: CMSampleBuffer) {
        sampleBufferOutputService.appendSampleBuffer(buffer)
    }
    
}



