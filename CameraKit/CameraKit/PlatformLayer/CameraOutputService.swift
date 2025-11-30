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


public protocol CameraContentPreviewService {
    var previewView: UIView {get}
    func updateFrame()
}


public protocol CameraContentRecordingService {
    var supportedOutput: CameraOutputAction {get}
    var outputState: CameraOutputState {get}
    func performAction( action: CameraOutputAction) async throws -> Bool
    
}

public protocol CameraOutputService {
    
    associatedtype PreviewService: CameraContentPreviewService
    associatedtype RecordingService: CameraContentRecordingService
    
    var previewService: PreviewService {get}
    var recordingService: RecordingService {get}
}

public enum CameraOutputState {
    case unknown
    case rendering
    case switching
    case recording
}


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

class CameraNonRecordingCameraService: CameraContentRecordingService {
    var outputState: CameraOutputState = .unknown
    
    func performAction(action: CameraOutputAction) throws -> Bool {
        guard self.supportedOutput.contains(action) else {
            throw CameraOutputAction.ActionError.invalidInput
        }
        throw CameraOutputAction.ActionError.unsupported
       
    }
    
    var supportedOutput: CameraOutputAction = [.normalView]
}

class CameraOutputImp: CameraOutputService {
   
    let previewService: CameraPreviewView
    let recordingService: CameraNonRecordingCameraService = CameraNonRecordingCameraService()
    
    init(session: AVCaptureSession) {
        previewService = CameraPreviewView(session: session)
    }
    
    
}
