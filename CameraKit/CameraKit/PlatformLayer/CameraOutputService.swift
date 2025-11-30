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


public protocol CameraOutputService {
    
    var previewView: UIView {get}
    func updateFrame()
    
    var supportedOutput: CameraOutputAction {get}
    
    var outputState: CameraOutputState {get}
    
    func performAction( action: CameraOutputAction) async throws -> Bool
    
}

public enum CameraOutputState {
    case unknown
    case rendering
    case switching
    case recording
}


final class CameraPreviewView: UIView {
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

class CameraOutputImp: CameraOutputService {
    var outputState: CameraOutputState = .unknown
    
    func performAction(action: CameraOutputAction) throws -> Bool {
        guard self.supportedOutput.contains(action) else {
            throw CameraOutputAction.ActionError.invalidInput
        }
        throw CameraOutputAction.ActionError.unsupported
       
    }
    
    var supportedOutput: CameraOutputAction = [.normalView]
    
    
    private var session:AVCaptureSession
    let previewView: UIView
    
    init(session: AVCaptureSession) {
        self.session = session
        previewView = CameraPreviewView(session: session)
    }
    
    func updateFrame () {
        previewView.setNeedsLayout()
        previewView.layoutIfNeeded()
    }
    
}
