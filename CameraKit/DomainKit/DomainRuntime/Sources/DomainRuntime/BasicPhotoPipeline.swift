//
//  BasicPhotoPipeline.swift
//  CameraKit
//
//  Created by Abhiraj on 08/10/23.
//

import Foundation
import AVFoundation
import CoreKit
import DomainApi
import PlatformApi
import Combine

/// Basic Camera Pipeline Use UIView and record on camera
class BasicPhotoPipeline: NSObject, @unchecked Sendable, CameraSubSystem {
   
    public  let displayCoordinator: any CameraDisplayCoordinator
    
    public var recordOutput: CameraDiskOutputService
    
    private let captureSession: AVCaptureSession
    public let sessionManager: CameraSessionService
    let photoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
    var imageCaptureConfig: ImageCaptureConfig  = ImageCaptureConfig()
   
    
    public init(platformFactory: PlatformFactory) {
        let session = AVCaptureSession()
        self.captureSession = session
        displayCoordinator = platformFactory.makeVideoLayerDisplayCoordinator(avcaptureSession: session)
        
        recordOutput = platformFactory.makePhotoOutputService(imageCaptureConfig: imageCaptureConfig)
        self.sessionManager = platformFactory.makeSessionService(session: session)
        super.init()
        
    }
    
    //@CameraInputSessionActor
    public func setup() async {
            let config = CameraInputConfig(photoResolution: imageCaptureConfig.resolution)
            await sessionManager.setup(input: [], output: recordOutput.availableOutput, config: config)
            await sessionManager.start()
    }
    
    //@CameraInputSessionActor
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

extension BasicPhotoPipeline {
    
    func updateSelection(filter: (any FilterModel)?)  {
    }
    
    var cameraModePublisher: CurrentValueSubject<CameraMode, Never> {
        return recordOutput.cameraModePublisher
    }
    
    func performAction( action: CameraAction) async throws -> Bool {
        return try await recordOutput.performAction(action:action)
    }
    
}
