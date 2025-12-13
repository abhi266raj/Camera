//
//  BasicPhotoPipeline.swift
//  CameraKit
//
//  Created by Abhiraj on 08/10/23.
//

import Foundation
import AVFoundation
import CoreKit
import PlatformKit_runtime
import DomainKit_api
import PlatformKit_api
import Combine

/// Basic Camera Pipeline Use UIView and record on camera
public class BasicPhotoPipeline: NSObject, @unchecked Sendable, CameraService {
   
    private let displayCoordinator: CameraLayerDisplayCoordinatorImp
    private let recordingService: CameraPhotoCameraService
    
    private let captureSession: AVCaptureSession
    public let sessionManager: CameraSessionHandlerImp
    let photoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
    private let processor = EmptyCameraProcessor()
    var imageCaptureConfig: ImageCaptureConfig {
        return recordingService.imageCaptureConfig
    }
    @MainActor
    public init(supportedCameraTask: SupportedCameraTask) {
        let session = AVCaptureSession()
        self.captureSession = session
        displayCoordinator = CameraLayerDisplayCoordinatorImp(session:session)
        recordingService = CameraPhotoCameraService()
        self.sessionManager = CameraSessionHandlerImp(session: session)
        super.init()
        
    }
    
    public func setup() {
        Task{
            @CameraInputSessionActor  in
            let config = CameraInputConfig(photoResolution: imageCaptureConfig.resolution)
            await sessionManager.setup(input: [], output: recordingService.availableOutput, config: config)
            await sessionManager.start()
        }
    }
    
    @CameraInputSessionActor
     public func toggleCamera() async -> Bool {
         let config = CameraInputConfig(photoResolution: imageCaptureConfig.resolution)
         return await sessionManager.toggle(config: config)
    }
    
    
    @MainActor
    public func attachDisplay(_ target: some CameraDisplayTarget) throws {
        Task {
            await try displayCoordinator.attach(target)
        }
    }
    
}

public extension BasicPhotoPipeline {
    
    func updateSelection(filter: (any FilterModel)?)  {
        processor.updateSelection(filter: filter)
    }
    
    var cameraModePublisher: CurrentValueSubject<CameraMode, Never> {
        return recordingService.cameraModePublisher
    }
    
    func performAction( action: CameraAction) async throws -> Bool {
        return try await recordingService.performAction(action:action)
    }
    
}
