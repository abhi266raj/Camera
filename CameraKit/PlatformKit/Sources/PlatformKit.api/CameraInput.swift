//
//  CameraInput.swift
//  PlatformKit
//
//  Created by Abhiraj on 07/12/25.
//

import AVFoundation
import CoreKit

public protocol CameraSessionService {
    func start() async
    func stop() async
    func update(config: CameraInputConfig) async -> Bool
    func setup(input: [AVCaptureInput], output: [AVCaptureOutput], config: CameraInputConfig) async -> Bool
}


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
    public var dimensions:CMVideoDimensions?
   
    public init(photoResolution:ImageCaptureConfig.PhotoResolution?) {
        self.dimensions = photoResolution?.maxDimension()
    }
}


public protocol MultiCameraInput: CameraInput {
    var frontCamera: AVCaptureDeviceInput? {get}
    var backCamera: AVCaptureDeviceInput? {get}
}
