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
    typealias OutputType = CameraPhotoOutputImp
    
    private let captureSession: AVCaptureSession
    let output: CameraPhotoOutputImp
    let input: InputType
    let photoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
    var processor = EmptyCameraProcessor()
    
    override init() {
        let session = AVCaptureSession()
        self.captureSession = session
        self.output = CameraPhotoOutputImp(session: session, photoOutput: photoOutput)
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
    
}
