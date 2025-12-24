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
    
    func makeMetalDisplayCoordinator(builder: @escaping () -> UIView) -> CameraDisplayCoordinator
    func makeMultiCameraDisplayCoordinator(avcaptureSession:AVCaptureMultiCamSession) -> CameraDisplayCoordinator
    func makeVideoLayerDisplayCoordinator(avcaptureSession: AVCaptureSession) -> CameraDisplayCoordinator
    
    func makePassThroughDiskRecordingService() -> AVCaptureDiskOutputService
    func makePhotoOutputService(imageCaptureConfig:ImageCaptureConfig) -> AVCaptureDiskOutputService
    func makeVideoOutputService(videoCaptureOutput: AVCaptureMovieFileOutput) -> AVCaptureDiskOutputService
    func makeSampleBufferOutputService(input: ContentInput) -> SampleBufferDiskOutputService
    
    func makeCameraInput() -> CameraInput
    
    func makeSessionService(session: AVCaptureSession) -> CameraSessionService
    
    func makeEffectProcessor() -> CameraProccessor
    
    func makePreviewMetalTarget() -> PreviewMetalTarget
}
