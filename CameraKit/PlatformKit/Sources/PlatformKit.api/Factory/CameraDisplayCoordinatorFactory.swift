//
//  CameraDisplayCoordinatorFactory.swift
//  PlatformKit
//
//  Created by Abhiraj on 16/12/25.
//

import AVFoundation
import UIKit

public protocol PlatformFactory {
    
    func makeMetalDisplayCoordinator(metalView: UIView) -> CameraDisplayCoordinator
    func makeMultiCameraDisplayCoordinator(avcaptureSession:AVCaptureMultiCamSession) -> CameraDisplayCoordinator
    func makeVideoLayerDisplayCoordinator(avcaptureSession: AVCaptureSession) -> CameraDisplayCoordinator
    
    func makePassThroughDiskRecordingService() -> CameraDiskOutputService
}
