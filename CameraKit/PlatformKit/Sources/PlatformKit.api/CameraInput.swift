//
//  CameraInput.swift
//  PlatformKit
//
//  Created by Abhiraj on 07/12/25.
//

import AVFoundation

public protocol CameraInput {
    func startRunning() async
    func stopRunning() async
    
    var audioDevice: AVCaptureDeviceInput? {get}
    var videoDevice: AVCaptureDeviceInput? {get}
    
    func toggleCamera() async -> Bool 
    
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
    
    public init(dimension: CMVideoDimensions, position: AVCaptureDevice.Position) {
        self.dimensions = dimension
        self.position = position
    }
}


public protocol MultiCameraInput: CameraInput {
    var frontCamera: AVCaptureDeviceInput? {get}
    var backCamera: AVCaptureDeviceInput? {get}
}
