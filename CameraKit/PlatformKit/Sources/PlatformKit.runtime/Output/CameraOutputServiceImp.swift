//
//  CameraOutput.swift
//  CameraKit
//
//  Created by Abhiraj on 16/10/23.
//

import Foundation
import AVFoundation
import UIKit
import Photos
import Combine
import PlatformKit_api


public class CameraPhotoOutputImp: CameraOutputService {
   
    public let previewService: CameraPreviewView
    public let recordingService: CameraPhotoCameraService
    
    @MainActor
    public init(session: AVCaptureSession, photoOutput: AVCapturePhotoOutput) {
        previewService = CameraPreviewView(session: session)
        recordingService = CameraPhotoCameraService(photoOutput: photoOutput)
    }
}

public class CameraVideoOutputImp: CameraOutputService {
    public let previewService: CameraPreviewView
    public let recordingService: CameraRecordingCameraService
    
    @MainActor
    public init(session: AVCaptureSession, videoCaptureOutput: AVCaptureMovieFileOutput) {
        previewService = CameraPreviewView(session: session)
        recordingService = CameraRecordingCameraService(videoCaptureOutput: videoCaptureOutput)
    }
}
