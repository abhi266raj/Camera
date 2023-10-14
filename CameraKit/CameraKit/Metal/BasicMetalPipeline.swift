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
class BasicMetalPipeline: NSObject, CameraPipelineProtocol, RenderingDelegate {
    func sampleBufferRendered(_ buffer: CMSampleBuffer) {
        videoRecorder?.appendSampleBuffer(buffer)
    }
    
    
    typealias InputType = CameraInput
    typealias ProcessorType = EffectCameraProcessor
    typealias OutputType = MetalOutput
    
    private let captureSession: AVCaptureSession
    let output: MetalOutput
    let input: InputType
    let bufferOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    let audioOutput: AVCaptureAudioDataOutput = AVCaptureAudioDataOutput()
    let videoQueue = DispatchQueue(label: "videoQueue")
    let audioQueue = DispatchQueue(label: "audioQueue")
    var videoRecorder: VideoRecorder?
    var processor = EffectCameraProcessor()
    
    
    override init() {
        let session = AVCaptureSession()
        self.captureSession = session
        self.output = MetalOutput(session: session)
        
        self.input = CameraInput()
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
    

    func start(_ record: Bool) {
        if record {
            // Start recording
            if videoRecorder == nil {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let videoOutputPath = (documentsPath as NSString).appendingPathComponent("output.mov")
                let videoOutputURL = URL(fileURLWithPath: videoOutputPath)
                
                let recorder = VideoRecorder(outputURL: videoOutputURL)
                recorder.startRecording()
                videoRecorder = recorder
                
            }
        } else {
            // Stop recording
            let recorder = videoRecorder
            videoRecorder = nil
            recorder?.stopRecording { url in
                self.save(outputFileURL: url, error: nil)
                // Handle recording completion here
                //self.videoRecorder = nil
            }
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let sampleBuffer = processor.process(sampleBuffer: sampleBuffer)
        if let videoPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            self.output.metalView.sampleBuffer = sampleBuffer
        }
        
        //videoRecorder?.appendSampleBuffer(buffer)
       
        
    }
    
     func save(outputFileURL: URL, error: Error?) {
        if let error = error {
            // Handle the error, e.g., display an error message.
            print("Error recording video: \(error.localizedDescription)")
            return
        }
        
        // Request permission to access the photo library.
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                // If permission is granted, save the video to the gallery.
                PHPhotoLibrary.shared().performChanges {
                    let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
                    request?.creationDate = Date()
                } completionHandler: { success, error in
                    if success {
                        // Video saved successfully.
                        print("Video saved to the gallery.")
                    } else if let error = error {
                        // Handle the error, e.g., display an error message.
                        print("Error saving video to the gallery: \(error.localizedDescription)")
                    }
                    
                    // Optionally, you can delete the temporary file.
                    do {
                        try FileManager.default.removeItem(at: outputFileURL)
                    } catch {
                        print("Error deleting temporary file: \(error.localizedDescription)")
                    }
                }
            } else {
                // Handle the case where permission is denied.
                print("Permission to access the photo library denied.")
            }
        }
    }
    
}


