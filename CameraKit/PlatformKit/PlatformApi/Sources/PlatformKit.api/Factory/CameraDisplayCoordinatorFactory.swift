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
    
    func makeMetalDisplayCoordinator() -> SampleBufferDisplayCoordinator
    func makeMultiCameraDisplayCoordinator(avcaptureSession:AVCaptureMultiCamSession) -> CameraDisplayCoordinator
    func makeVideoLayerDisplayCoordinator(avcaptureSession: AVCaptureSession) -> CameraDisplayCoordinator
    
    
    func makePhotoClickWorker() -> PhotoClickWorker
    func makeBasicVideoRecordWorker() -> BasicVideoRecordWorker
    
    func makeSampleBufferOutputService() -> SampleBufferVideoRecordingWorker
    
    func makeCameraInput() -> CameraInput
    
    func makeSessionService() -> CameraSessionService
    
    func makeEffectProcessor() -> CameraProccessor
    
    func makePreviewMetalTarget() -> PreviewMetalTarget
    
    func makeFilterModelSelection() -> FilterModelSelectionStream
}
