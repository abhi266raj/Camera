//
//  CameraDisplayCoordinatorFactoryImp.swift
//  PlatformKit
//
//  Created by Abhiraj on 16/12/25.
//
import Foundation
import AVFoundation
import PlatformKit_api
import CoreKit
import UIKit


public class PlatformFactoryImp: PlatformFactory {
    public func makeEffectProcessor() -> any CameraProccessor {
        EffectCameraProcessor()
    }
    
    public func makeSessionService(session: AVCaptureSession) -> any CameraSessionService {
        CameraSessionHandlerImp(session: session)
    }
    
    public init() {}
    
    public func makeMetalDisplayCoordinator(metalView: UIView) -> CameraDisplayCoordinator {
        return CameraMetalDisplayCoordinatorImp(metalView: metalView)
    }
    
    public func makeMultiCameraDisplayCoordinator(avcaptureSession: AVCaptureMultiCamSession) -> CameraDisplayCoordinator {
        MultiCameraDisplayCoordinator(session: avcaptureSession)
        
    }
    
    public func makeVideoLayerDisplayCoordinator(avcaptureSession: AVCaptureSession) -> CameraDisplayCoordinator {
        CameraLayerDisplayCoordinatorImp(session: avcaptureSession)
    }
    
    public func makePassThroughDiskRecordingService() -> any CameraDiskOutputService {
        PreviewOnlyService()
    }
    
    public func makeCameraInput() -> any CameraInput {
        CameraInputImp()
    }
}
