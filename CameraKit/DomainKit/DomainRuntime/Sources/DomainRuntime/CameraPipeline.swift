//
//  CameraPipelineImp.swift
//  CameraKit
//
//  Created by Abhiraj on 30/11/25.
//
import Foundation
import AVFoundation
import UIKit
import CoreKit
import DomainApi

//public class CameraPipeline: NSObject, AVCaptureFileOutputRecordingDelegate, CameraPipelineServiceNew {
// 
//    private let captureSession: AVCaptureSession
//    public let output: CameraVideoOutputImp
//    public let input: CameraInputImp
//    public var processor: EffectCameraProcessor
//    let fileOutput = AVCaptureMovieFileOutput()
//    
//    @MainActor
//    public init(cameraOutputAction: CameraAction) {
//        let session = AVCaptureSession()
//        self.captureSession = session
//        self.output = CameraVideoOutputImp(session: session, videoCaptureOutput: fileOutput)
//        self.processor = EffectCameraProcessor()
//        self.input = CameraInputImp()
//    }
//
//    @CameraInputSessionActor public func setup() async  {
//        let _  = setupInputAndOutput()
//                input.session = captureSession
//                input.startRunning()
//    }
//    
//    private func setupInputAndOutput() -> Bool {
//        guard let videoDevice =  input.videoDevice else {return false}
//        guard let audioDevice =  input.audioDevice else {return false}
//        captureSession.beginConfiguration()
//        defer {
//            captureSession.commitConfiguration()
//        }
//        if captureSession.canAddInput(videoDevice) {
//            captureSession.addInput(videoDevice)
//        }else{
//            return false
//        }
//        
//        if captureSession.canAddInput(audioDevice) {
//            captureSession.addInput(audioDevice)
//        }else{
//            return false
//        }
//        
//        if captureSession.canAddOutput(fileOutput) {
//            captureSession.addOutput(fileOutput)
//        }else {
//            return false
//        }
//       
//        return true
//    }
//    
//    var isRecording: Bool = false
//    func start(_ record: Bool) {
//        if record == true {
//            guard isRecording == false else {return}
//            isRecording = true
//            let outputFilePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("A \(UUID().uuidString).mov")!
//            fileOutput.startRecording(to: outputFilePath, recordingDelegate: self)
//        }else {
//            isRecording = false
//            fileOutput.stopRecording()
//        }
//    }
//    
//    
//    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
//        if let error = error {
//            // Handle the error, e.g., display an error message.
//            print("Error recording video: \(error.localizedDescription)")
//            return
//        }
//        
//        // Request permission to access the photo library.
//        PHPhotoLibrary.requestAuthorization { status in
//            if status == .authorized {
//                // If permission is granted, save the video to the gallery.
//                PHPhotoLibrary.shared().performChanges {
//                    let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
//                    request?.creationDate = Date()
//                } completionHandler: { success, error in
//                    if success {
//                        // Video saved successfully.
//                        print("Video saved to the gallery.")
//                    } else if let error = error {
//                        // Handle the error, e.g., display an error message.
//                        print("Error saving video to the gallery: \(error.localizedDescription)")
//                    }
//                    
//                    // Optionally, you can delete the temporary file.
//                    do {
//                        try FileManager.default.removeItem(at: outputFileURL)
//                    } catch {
//                        print("Error deleting temporary file: \(error.localizedDescription)")
//                    }
//                }
//            } else {
//                // Handle the case where permission is denied.
//                print("Permission to access the photo library denied.")
//            }
//        }
//    }
//
//    
//}
