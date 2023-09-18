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
    associatedtype ProcessorType
    
    var input: InputType {get}
    var output: OutputType {get}
    
    func setup()
    
}

protocol CameraOutputProtocol {
    
    var previewView: UIView {get}
    
}

class CameraOutput: CameraOutputProtocol {
    
    private var session:AVCaptureSession
    var previewView: UIView
    var previewLayer: AVCaptureVideoPreviewLayer
    
    init(session: AVCaptureSession) {
        self.session = session
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewView = UIView(frame: CGRectMake(0, 0, 200, 200))
        previewView.backgroundColor = .green
        previewLayer.frame = previewView.bounds
        previewView.layer.addSublayer(previewLayer)
    }
    
}

protocol CameraProccessorProtocol {
    
}




class CameraPipeline: CameraPipelineProtocol {
   
    
    typealias InputType = CameraInput
    typealias ProcessorType = CameraPipeline
    typealias OutputType = CameraOutput
 
    private let captureSession: AVCaptureSession = AVCaptureSession()
    lazy var output = CameraOutput(session: captureSession)
    var input: InputType = CameraInput()

    func setup() {
        let _  = setupInput()
         Task { @CameraInputSession in
                 input.session = captureSession
                 input.startRunning()
        }
    }
    
    private func setupInput() -> Bool {
        guard let device =  input.videoDevice else {return false}
        captureSession.beginConfiguration()
        defer {
            captureSession.commitConfiguration()
        }
        if captureSession.canAddInput(device) {
            captureSession.addInput(device)
        }else{
            return false
        }
       
        return true
    }

    
}

