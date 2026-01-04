//
//  CameraInput.swift
//  PlatformKit
//
//  Created by Abhiraj on 07/12/25.
//

import AVFoundation
import CoreKit


public protocol CameraInput: Sendable {
    var audioDevice: AVCaptureDeviceInput? {get}
    var frontCamera: AVCaptureDeviceInput? {get}
    var backCamera: AVCaptureDeviceInput? {get}
}

public class SessionConfig: @unchecked Sendable {
    public var videoDevice: [AVCaptureDeviceInput] = []
    public var audioDevice: [AVCaptureDeviceInput] = []
    public var videoResolution: CMVideoDimensions? = nil
    public var contentOutput: [AVCaptureOutput] = []
    
    public init() {
        
    }
}

public class SessionState: @unchecked Sendable {
    public var selectedVideoDevice: [AVCaptureDeviceInput] = []
    
    public init() {
        
    }
    
    public func update(_ device:[AVCaptureDeviceInput]) async {
        await selectedVideoDevice = device
    }
}


public protocol CameraSessionService: Sendable {
    func apply(_ config: SessionConfig, session: AVCaptureSession) async throws
}




 private extension ImageCaptureConfig.PhotoResolution {
    public func maxDimension() -> CMVideoDimensions {
        switch self {
        case .hd1080:
            return CMVideoDimensions(width: 1920, height: 1080)
        case .hd720:
            return CMVideoDimensions(width: 1280, height: 720)
        case .vga640:
            return CMVideoDimensions(width: 640, height: 480)
        }
    }
}


public struct CameraInputConfig {
    public var dimensions:CMVideoDimensions?
   
    public init(photoResolution:ImageCaptureConfig.PhotoResolution?) {
        self.dimensions = photoResolution?.maxDimension()
    }
    
    public init() {
        
    }
}



