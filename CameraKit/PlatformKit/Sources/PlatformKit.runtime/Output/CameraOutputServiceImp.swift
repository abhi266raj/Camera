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


public class CameraVideoOutputImp: CameraOutputService {
    public let previewService: CameraPreviewView
    public let recordingService: CameraRecordingCameraService
    
    @MainActor
    public init(session: AVCaptureSession, videoCaptureOutput: AVCaptureMovieFileOutput) {
        previewService = CameraPreviewView(session: session)
        recordingService = CameraRecordingCameraService(videoCaptureOutput: videoCaptureOutput)
    }
}
