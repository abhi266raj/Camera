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
internal import UIKit

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
    private var metalView: PreviewMetalTarget? {
        return metalRenderingDelegateImp.metalView
    }
    private let metalRenderingDelegateImp: MetalRenderingDelegateImp
    private var streamTask : Task<Void, Never>?

    public init(platformFactory: PlatformFactory, stream: AsyncStream<FilterModel>) {
        let session = AVCaptureSession()
        self.captureSession = session
        sampleBufferOutputService = platformFactory.makeSampleBufferOutputService()
        let metalRenderingDelegateImp = MetalRenderingDelegateImp(sampleBufferOutputService: sampleBufferOutputService)
        let viewBuilder: () -> UIView = {
            let metalView = platformFactory.makePreviewMetalTarget()
            metalView.renderingDelegate = metalRenderingDelegateImp
            metalRenderingDelegateImp.metalView = metalView
            return metalView
        }
        displayCoordinator = platformFactory.makeMetalDisplayCoordinator(builder: viewBuilder)
        self.metalRenderingDelegateImp = metalRenderingDelegateImp
        self.input = platformFactory.makeCameraInput()
        let effectProcessor = platformFactory.makeEffectProcessor()
        self.processor = effectProcessor
        
        super.init()
        bufferOutput.setSampleBufferDelegate(self, queue: videoQueue)
        audioOutput.setSampleBufferDelegate(self, queue: audioQueue)
        self.streamTask = Task { @MainActor in
            for await filter in stream {
                self.processor.selectedFilter = filter
            }
        }
        
    }
    
    @MainActor func handleFilter(stream: AsyncStream<FilterModel>, processor: CameraProccessor?) async {
        for await filter in stream {
            self.processor.selectedFilter = filter
        }
        
    }
    
    public func setup() async {
            let _  = self.setupInputAndOutput()
            self.input.session = self.captureSession
            await self.input.startRunning()
    }
    
    public func start() async {
            await self.input.startRunning()
    }
    
    public func stop() async {
        await self.input.stopRunning()
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
            self.metalRenderingDelegateImp.metalView?.captureOutput?(output, didOutput: sampleBuffer, from: connection)
        }else{
            // Audio delegate record it
            self.sampleBufferOutputService.appendSampleBuffer(sampleBuffer)
        }
      
    }
    
}


extension BasicMetalPipeline: MetalRenderingDelegate {
    func sampleBufferRendered(_ buffer: CMSampleBuffer) {
        sampleBufferOutputService.appendSampleBuffer(buffer)
    }
}


class MetalRenderingDelegateImp: MetalRenderingDelegate {
    let sampleBufferOutputService: SampleBufferDiskOutputService
    var metalView: PreviewMetalTarget?
    
    init(sampleBufferOutputService: SampleBufferDiskOutputService) {
        self.sampleBufferOutputService = sampleBufferOutputService
    }
    
    func sampleBufferRendered(_ buffer: CMSampleBuffer) {
        sampleBufferOutputService.appendSampleBuffer(buffer)
    }
}



