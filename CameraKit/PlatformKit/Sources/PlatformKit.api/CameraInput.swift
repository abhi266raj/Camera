//
//  CameraInput.swift
//  PlatformKit
//
//  Created by Abhiraj on 07/12/25.
//

import AVFoundation
import CoreKit

public protocol CameraInput {
    func startRunning() async
    func stopRunning() async
    
    var audioDevice: AVCaptureDeviceInput? {get}
    var videoDevice: AVCaptureDeviceInput? {get}
    
    func toggleCamera() async -> Bool 
    
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
    public var dimensions:CMVideoDimensions
    public var position: AVCaptureDevice.Position
    
    public init(frontWith dimensions: CMVideoDimensions) {
        self.dimensions = dimensions
        self.position = .front
    }
    
    public init (backWith dimensions: CMVideoDimensions) {
        self.dimensions = dimensions
        self.position = .back
    }
    
    public init(photoResolution:ImageCaptureConfig.PhotoResolution, position: AVCaptureDevice.Position ) {
        self.dimensions = photoResolution.maxDimension()
        self.position = position
    }
}


public protocol MultiCameraInput: CameraInput {
    var frontCamera: AVCaptureDeviceInput? {get}
    var backCamera: AVCaptureDeviceInput? {get}
}
