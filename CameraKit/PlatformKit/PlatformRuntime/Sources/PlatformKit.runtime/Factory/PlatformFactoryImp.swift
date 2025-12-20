//
//  PlatformFactoryImp.swift
//  CameraKit
//
//  Created by Abhiraj on 18/12/25.
//


import Foundation
import AVFoundation
import PlatformApi
import CoreKit
import UIKit


final class PlatformFactoryImp: PlatformFactory {
    func makeSampleBufferOutputService() -> any SampleBufferDiskOutputService {
        SampleBufferCameraRecorderService()
    }
    
    func makePreviewMetalTarget() -> any PreviewMetalTarget {
        PreviewMetalView(frame: .zero)
    }
    
    func makePhotoOutputService(imageCaptureConfig:ImageCaptureConfig) -> any AVCaptureDiskOutputService {
        CameraPhotoCameraService(imageCaptureConfig: imageCaptureConfig)
    }
    
    func makeVideoOutputService(videoCaptureOutput: AVCaptureMovieFileOutput) -> any AVCaptureDiskOutputService {
        CameraRecordingCameraService(videoCaptureOutput: videoCaptureOutput)
    }
    
    lazy var effectProcessor = EffectCameraProcessor()
    func makeEffectProcessor() -> any CameraProccessor {
        effectProcessor
    }
    
    func makeSessionService(session: AVCaptureSession) -> any CameraSessionService {
        CameraSessionHandlerImp(session: session)
    }
    
    public init() {}
    
    func makeMetalDisplayCoordinator(metalView: UIView) -> CameraDisplayCoordinator {
        return CameraMetalDisplayCoordinatorImp(metalView: metalView)
    }
    
    func makeMultiCameraDisplayCoordinator(avcaptureSession: AVCaptureMultiCamSession) -> CameraDisplayCoordinator {
        MultiCameraDisplayCoordinator(session: avcaptureSession)
        
    }
    
    func makeVideoLayerDisplayCoordinator(avcaptureSession: AVCaptureSession) -> CameraDisplayCoordinator {
        CameraLayerDisplayCoordinatorImp(session: avcaptureSession)
    }
    
    func makePassThroughDiskRecordingService() -> any AVCaptureDiskOutputService {
        PreviewOnlyService()
    }
    
    func makeCameraInput() -> any CameraInput {
        CameraInputImp()
    }
}
