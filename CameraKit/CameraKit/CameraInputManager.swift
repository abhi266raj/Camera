//
//  CameraInputManager.swift
//  CameraKit
//
//  Created by Abhiraj on 17/09/23.
//

import Foundation
import AVFoundation
import AssetsLibrary
import UIKit
import Photos


protocol CameraInputProtocol {
    func startRunning() async
    func stopRunning() async
    
    var audioDevice: AVCaptureDeviceInput? {get}
    var videoDevice: AVCaptureDeviceInput? {get}
    
}

@globalActor
actor CameraInputSession {
    static var shared =  CameraInputSession()
}

@CameraInputSession
class CameraInput: CameraInputProtocol {
    var session: AVCaptureSession?
    
    nonisolated init() {
        
    }
    
    func startRunning() {
        session?.startRunning()
    }
    
    func stopRunning() {
        session?.stopRunning()
    }
    
    nonisolated var audioDevice: AVCaptureDeviceInput? {
        let device =  AVCaptureDevice.default(for: .audio)
        guard let device else {return nil}
        do {
            let input = try AVCaptureDeviceInput(device: device)
            return input
        }catch {
            return nil
        }
    }
    
    nonisolated var videoDevice: AVCaptureDeviceInput? {
        let device =  AVCaptureDevice.default(for: .video)
        guard let device else {return nil}
        do {
            let input = try AVCaptureDeviceInput(device: device)
            return input
        }catch {
            return nil
        }
    }
    
}

protocol CameraPipelineProtocol {
    associatedtype InputType: CameraInputProtocol
    associatedtype OutputType: CameraOutputProtocol
    associatedtype ProcessorType: CameraProccessorProtocol
    
    var input: InputType {get}
    var output: OutputType {get}
    var processor: ProcessorType {get}
    
    func setup()
    
    func start(_ record: Bool)
    
}

protocol CameraOutputProtocol {
    
    var previewView: UIView {get}
    func updateFrame()
    
}

class CameraOutput: CameraOutputProtocol {
    
    private var session:AVCaptureSession
    var previewView: UIView
    private var previewLayer: AVCaptureVideoPreviewLayer
    
    init(session: AVCaptureSession) {
        self.session = session
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewView = UIView(frame: CGRectMake(100, 100, 100, 100))
        previewView.backgroundColor = .green
        previewLayer.frame = previewView.bounds
        previewView.layer.addSublayer(previewLayer)
    }
    
    func updateFrame () {
        if previewView.bounds != CGRectZero {
            previewLayer.frame = previewView.frame
        }
        
    }
    
}

protocol CameraProccessorProtocol {
    func process(sampleBuffer: CMSampleBuffer) -> CMSampleBuffer
}




class CameraPipeline: NSObject, AVCaptureFileOutputRecordingDelegate {
    
    typealias InputType = CameraInput
    typealias ProcessorType = EffectCameraProcessor
    typealias OutputType = CameraOutput
 
    private let captureSession: AVCaptureSession
    let output: CameraOutput
    let input: InputType
    let fileOutput = AVCaptureMovieFileOutput()
    
    override init() {
        let session = AVCaptureSession()
        self.captureSession = session
        self.output = CameraOutput(session: session)
        self.input = CameraInput()
    }

    func setup() {
        let _  = setupInputAndOutput()
            Task{ @CameraInputSession in
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
        
        if captureSession.canAddOutput(fileOutput) {
            captureSession.addOutput(fileOutput)
        }else {
            return false
        }
       
        return true
    }
    
    var isRecording: Bool = false
    func start(_ record: Bool) {
        if record == true {
            guard isRecording == false else {return}
            isRecording = true
            let outputFilePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("A \(UUID().uuidString).mov")!
            fileOutput.startRecording(to: outputFilePath, recordingDelegate: self)
        }else {
            isRecording = false
            fileOutput.stopRecording()
        }
    }
    
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
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

