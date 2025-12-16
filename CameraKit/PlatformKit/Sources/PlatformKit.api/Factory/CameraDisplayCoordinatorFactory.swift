//
//  CameraDisplayCoordinatorFactory.swift
//  PlatformKit
//
//  Created by Abhiraj on 16/12/25.
//

import AVFoundation
import UIKit
import CoreKit

public protocol PlatformFactory {
    
    func makeMetalDisplayCoordinator(metalView: UIView) -> CameraDisplayCoordinator
    func makeMultiCameraDisplayCoordinator(avcaptureSession:AVCaptureMultiCamSession) -> CameraDisplayCoordinator
    func makeVideoLayerDisplayCoordinator(avcaptureSession: AVCaptureSession) -> CameraDisplayCoordinator
    
    func makePassThroughDiskRecordingService() -> CameraDiskOutputService
    func makePhotoOutputService(imageCaptureConfig:ImageCaptureConfig) -> CameraDiskOutputService
    func makeVideoOutputService(videoCaptureOutput: AVCaptureMovieFileOutput) -> CameraDiskOutputService
    func makeSampleBufferOutputService() -> CameraDiskOutputService
    
    func makeCameraInput() -> CameraInput
    
    func makeSessionService(session: AVCaptureSession) -> CameraSessionService
    
    func makeEffectProcessor() -> CameraProccessor
    
    func makePreviewMetalTarget() -> PreviewMetalTarget
}
