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
import CoreMedia

/// Basic Camera Pipeline Use UIView and record on camera
class BasicMetalPipeline: NSObject, CameraPipelineServiceNew, RenderingDelegate {
    
    func sampleBufferRendered(_ buffer: CMSampleBuffer) {
        recordOutput.appendSampleBuffer(buffer)
    }
        
    private let captureSession: AVCaptureSession
    let previewOutput: MetalCameraPreviewView
    let recordOutput: SampleBufferCameraRecorderService

    let input: CameraInputImp
    let bufferOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    let audioOutput: AVCaptureAudioDataOutput = AVCaptureAudioDataOutput()
    let videoQueue = DispatchQueue(label: "videoQueue")
    let audioQueue = DispatchQueue(label: "audioQueue")
    //var processor = EmptyCameraProcessor()
    var processor: EffectCameraProcessor = EffectCameraProcessor()
    
    
    init(cameraOutputAction: CameraAction) {
        let session = AVCaptureSession()
        self.captureSession = session
        let videoOutput = VideoOutputImp()
        recordOutput = SampleBufferCameraRecorderService(videoOutput: videoOutput)
        let metalView = PreviewMetalView(frame: .zero)
        previewOutput = MetalCameraPreviewView(metalView: metalView)
        self.input = CameraInputImp()
        super.init() 
        bufferOutput.setSampleBufferDelegate(self, queue: videoQueue)
        audioOutput.setSampleBufferDelegate(self, queue: audioQueue)
        previewOutput.metalView.renderingDelegate = self
    }
    
    func setup() {
        Task{ @CameraInputSession in
            let _  = setupInputAndOutput()
            input.session = captureSession
            input.startRunning()
        }
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
            //session.addOutput(videoDataOutput)
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

}

extension BasicMetalPipeline: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let sampleBuffer = processor.process(sampleBuffer: sampleBuffer)
        if CMSampleBufferGetImageBuffer(sampleBuffer) != nil {
            // Image render it than use via delegate to record
            self.previewOutput.metalView.sampleBuffer = sampleBuffer
        }else{
            // Audio delegate record it
            self.recordOutput.appendSampleBuffer(sampleBuffer)
        }
      
    }
    
}


