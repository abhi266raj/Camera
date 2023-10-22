//
//  BasicPhotoPipeline.swift
//  CameraKit
//
//  Created by Abhiraj on 08/10/23.
//

import Foundation
import AVFoundation
import AssetsLibrary
import UIKit
import Photos
import CoreMedia

/// Basic Camera Pipeline Use UIView and record on camera
class BasicMetalPipeline: NSObject, CameraPipeline, RenderingDelegate {
    
    
    func sampleBufferRendered(_ buffer: CMSampleBuffer) {
        output.appendSampleBuffer(buffer)
    }
        
    private let captureSession: AVCaptureSession
    let output: MetalOutput
    let input: CameraInputImp
    let bufferOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    let audioOutput: AVCaptureAudioDataOutput = AVCaptureAudioDataOutput()
    let videoQueue = DispatchQueue(label: "videoQueue")
    let audioQueue = DispatchQueue(label: "audioQueue")
    //var processor = EmptyCameraProcessor()
    var processor = EffectCameraProcessor()
    
    
    override init() {
        let session = AVCaptureSession()
        self.captureSession = session
        self.output = MetalOutput(session: session)
        
        self.input = CameraInputImp()
        super.init() 
        bufferOutput.setSampleBufferDelegate(self, queue: videoQueue)
        audioOutput.setSampleBufferDelegate(self, queue: audioQueue)
        output.metalView.renderingDelegate = self
        
       
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
            self.output.metalView.sampleBuffer = sampleBuffer
        }else{
            self.output.appendSampleBuffer(sampleBuffer)
        }
      
    }
    
}


