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


/// Basic Camera Pipeline Use UIView and record on camera
class BasicPhotoPipeline: NSObject, CameraPipelineService {
    
    typealias InputType = CameraInputImp
    typealias ProcessorType = EmptyCameraProcessor
    typealias OutputType = CameraOutputImp
    
    private let captureSession: AVCaptureSession
    let output: CameraOutputImp
    let input: InputType
    let photoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
    var processor = EmptyCameraProcessor()
    
    override init() {
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
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }else {
            return false
        }
        
        return true
    }
    
    
    func start(_ record: Bool) {
        let photoSettings = AVCapturePhotoSettings()
        //photoSettings.isAutoStillImageStabilizationEnabled = true
        
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
}

extension BasicPhotoPipeline : AVCapturePhotoCaptureDelegate {
    
    // AVCapturePhotoCaptureDelegate method to handle captured photo
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            // Save the captured image to the Photos library
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    PHPhotoLibrary.shared().performChanges {
                        let creationRequest = PHAssetCreationRequest.forAsset()
                        creationRequest.addResource(with: .photo, data: imageData, options: nil)
                    } completionHandler: { success, error in
                        if success {
                            // The image was successfully saved to the Photos library
                            DispatchQueue.main.async {
                                // Handle UI updates or feedback to the user if needed
                                print("Image saved to Photos library")
                            }
                        } else if let error = error {
                            // Handle the error
                            print("Error saving image to Photos library: \(error.localizedDescription)")
                        }
                    }
                } else {
                    // Handle the case where permission to access the Photos library is denied
                    print("Permission to access Photos library denied")
                }
            }
        }
    }
}




