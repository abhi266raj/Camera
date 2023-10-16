//
//  BasicCameraPipeline.swift
//  CameraKit
//
//  Created by Abhiraj on 08/10/23.
//

import Foundation
import AVFoundation
import AssetsLibrary
import UIKit
import Photos


/// Basic Camera Pipeline Use UIView and record on camera
class BasicVideoPipeline:  CameraPipeline {
    
    typealias InputType = CameraInputImp
    typealias ProcessorType = EmptyCameraProcessor
    typealias OutputType = CameraOutputImp
 
    private let captureSession: AVCaptureSession
    let output: CameraOutputImp
    let input: InputType
    let fileOutput = AVCaptureMovieFileOutput()
    let processor = EmptyCameraProcessor()
    
    init() {
        let session = AVCaptureSession()
        self.captureSession = session
        self.output = CameraOutputImp(session: session)
        self.input = CameraInputImp()
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
        
        if captureSession.canAddOutput(fileOutput) {
            captureSession.addOutput(fileOutput)
        }else {
            return false
        }
       
        return true
    }
    
    var basicFileRecorder: BasicFileRecorder?
    func start(_ record: Bool) {
        if basicFileRecorder == nil {
                basicFileRecorder = BasicFileRecorder(fileOutput: fileOutput)
        }
        Task {
            await basicFileRecorder?.start(record)
        }
        
    }
    
}


actor BasicFileRecorder: NSObject, AVCaptureFileOutputRecordingDelegate {
    
    var fileOutput: AVCaptureMovieFileOutput
    var isRecording = false
    
    init(fileOutput: AVCaptureMovieFileOutput) {
        self.fileOutput = fileOutput
        super.init()
       
        
    }
    
    func start(_ record: Bool) {
        if record {
            if !isRecording {
                isRecording = true
                let outputFilePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("A \(UUID().uuidString).mov")!
                fileOutput.startRecording(to: outputFilePath, recordingDelegate: self)
            }
        }else {
            fileOutput.stopRecording()
            isRecording = false
        }
    }
    
    
    
    deinit {
        fileOutput.stopRecording()
    }
    
    nonisolated func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
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


