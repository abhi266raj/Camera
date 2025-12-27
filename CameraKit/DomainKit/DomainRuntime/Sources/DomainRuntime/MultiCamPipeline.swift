//
//  MultiCamPipeline.swift
//  DomainKit
//
//  Created by Abhiraj on 09/12/25.
//

internal import AVFoundation
import CoreKit
import DomainApi
import PlatformApi

/// Multi Camera Pipeline Use UIView and record on camera
class MultiCamPipeline: NSObject, CameraSubSystem, @unchecked Sendable {

    public var input: CameraInput
    public let displayCoordinator: any CameraSessionDisplayCoordinator
    private let captureSession: AVCaptureMultiCamSession
    
    public init(platformFactory: PlatformFactory) {
        let session = AVCaptureMultiCamSession()
        self.captureSession = session
        displayCoordinator = platformFactory.makeMultiCameraDisplayCoordinator()
        self.input = platformFactory.makeCameraInput()
        super.init()
        
        
    }

    public func setup() async {
       // Task{ @CameraInputSessionActor  in
            await self.setupInput()
        //}
    }
    
    //@CameraInputSessionActor
    private func setupInput() async {
        let _  = self.setupInputAndOutput()
        await captureSession.startRunning()
        
    }
    
    public func start() async {
            await captureSession.startRunning()
    }
    
    public func stop() async {
        await captureSession.stopRunning()
    }
    
    var ports:[AVCaptureInput.Port] = []
    
    private func setupInputAndOutput() -> Bool {
        guard let frontCamera = input.frontCamera else {return false}
        guard let backCamera = input.backCamera else {return false}
        guard let audioDevice =  input.audioDevice else {return false}
        captureSession.beginConfiguration()
        defer {
            captureSession.commitConfiguration()
        }
        
        if captureSession.canAddInput(backCamera) {
            captureSession.addInput(backCamera)
        }else{
            return false
        }
        
        if captureSession.canAddInput(frontCamera) {
            captureSession.addInput(frontCamera)
        }else{
            return false
        }
        
        if captureSession.canAddInput(audioDevice) {
            captureSession.addInput(audioDevice)
        }else{
            return false
        }
        
        guard backCamera.ports.count > 0, frontCamera.ports.count > 0 else {
            return false
        }
        return true
    }
    
    public func toggleCamera() async -> Bool {
        await updatePort()
        return true
    }
    
    @MainActor
    public func updatePort() {
        captureSession.beginConfiguration()
        let connection = captureSession.connections
        let port0 = connection[0].inputPorts[0]
        let layer0 = connection[0].videoPreviewLayer!
        let port1 = connection[1].inputPorts[0]
        let layer1 = connection[1].videoPreviewLayer!
        captureSession.removeConnection(connection[0])
        captureSession.removeConnection(connection[1])
        let frontConnection = AVCaptureConnection(inputPort: port0, videoPreviewLayer: layer1)
        let backConnection = AVCaptureConnection(inputPort: port1, videoPreviewLayer: layer0)
        captureSession.addConnection(frontConnection)
        captureSession.addConnection(backConnection)
        captureSession.commitConfiguration()
    }
    
    
    @MainActor
    public func attachDisplay(_ target: some CameraDisplayTarget) throws {
        Task {
            displayCoordinator.updateSession(session: captureSession)
            await try displayCoordinator.attach(target)
        }
    }
    
    var cameraModePublisher: AsyncSequence<CameraMode, Never> {
        AsyncStream { continuation in
            continuation.yield(.preview)
        }
    }
    
    func performAction( action: CameraAction) async throws -> Bool {
        return false
    }
    
}

