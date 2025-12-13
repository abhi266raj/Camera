//
//  BasicCameraPipeline.swift
//  CameraKit
//
//  Created by Abhiraj on 08/10/23.
//

import AVFoundation
import UIKit
import CoreKit
import PlatformKit_runtime
import DomainKit_api
import PlatformKit_api

/// Basic Camera Pipeline Use UIView and record on camera
public class BasicVideoPipeline:  CameraPipelineService, @unchecked Sendable {
    
    public typealias InputType = CameraInputImp
    public typealias ProcessorType = EmptyCameraProcessor
    public typealias OutputType = CameraVideoOutputImp
 
    private let cameraDisplayCoordinator: CameraLayerDisplayCoordinatorImp
    private let captureSession: AVCaptureSession
    public let output: CameraVideoOutputImp
    public let input: InputType
    let fileOutput = AVCaptureMovieFileOutput()
    public var processor = EmptyCameraProcessor()
    var videoRecordingConfig =  VideoRecordingConfig()
    
    @MainActor
    public init(cameraOutputAction: CameraAction) {
        let session = AVCaptureSession()
        self.captureSession = session
        self.output = CameraVideoOutputImp(session: session, videoCaptureOutput: fileOutput)
        self.input = CameraInputImp()
        cameraDisplayCoordinator = CameraLayerDisplayCoordinatorImp(session:session)
    }

    public func setup() {
            Task{ @CameraInputSessionActor in
                let _  = setupInputAndOutput()
                input.session = captureSession
                input.startRunning()
            }
    }
    
    @MainActor
    public func attachDisplay(_ target: some CameraDisplayTarget) throws {
        Task {
            await try cameraDisplayCoordinator.attach(target)
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
