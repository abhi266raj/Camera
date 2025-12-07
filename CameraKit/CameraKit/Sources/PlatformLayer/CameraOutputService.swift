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
import PlatformKit_runtime


final class CameraPreviewView: UIView, CameraContentPreviewService {
    var previewView: UIView {
        return self
    }
    
    func updateFrame() {
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    private let previewLayer: AVCaptureVideoPreviewLayer

    init(session: AVCaptureSession) {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
        self.previewLayer.videoGravity = .resizeAspectFill
        super.init(frame: .zero)
        layer.addSublayer(previewLayer)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
    }
}

class CameraPhotoOutputImp: CameraOutputService {
   
    let previewService: CameraPreviewView
    let recordingService: CameraPhotoCameraService
    
    init(session: AVCaptureSession, photoOutput: AVCapturePhotoOutput) {
        previewService = CameraPreviewView(session: session)
        recordingService = CameraPhotoCameraService(photoOutput: photoOutput)
    }
}

class CameraVideoOutputImp: CameraOutputService {
    let previewService: CameraPreviewView
    let recordingService: CameraRecordingCameraService
    
    init(session: AVCaptureSession, videoCaptureOutput: AVCaptureMovieFileOutput) {
        previewService = CameraPreviewView(session: session)
        recordingService = CameraRecordingCameraService(videoCaptureOutput: videoCaptureOutput)
    }
}
