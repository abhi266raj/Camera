//
//  BasicCameraPipeline.swift
//  CameraKit
//
//  Created by Abhiraj on 08/10/23.
//

import Foundation
import AVFoundation
import UIKit
import Photos
import CoreKit
import PlatformKit_runtime


/// Basic Camera Pipeline Use UIView and record on camera
class BasicVideoPipeline:  CameraPipelineService {
    
    typealias InputType = CameraInputImp
    typealias ProcessorType = EmptyCameraProcessor
    typealias OutputType = CameraVideoOutputImp
 
    private let captureSession: AVCaptureSession
    let output: CameraVideoOutputImp
    let input: InputType
    let fileOutput = AVCaptureMovieFileOutput()
    var processor = EmptyCameraProcessor()
    
    init(cameraOutputAction: CameraAction) {
        let session = AVCaptureSession()
        self.captureSession = session
        self.output = CameraVideoOutputImp(session: session, videoCaptureOutput: fileOutput)
        self.input = CameraInputImp()
    }

    func setup() {
            Task{ @CameraInputSessionActor in
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


