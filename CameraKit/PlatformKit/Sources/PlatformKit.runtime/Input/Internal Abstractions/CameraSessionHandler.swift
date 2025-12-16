//
//  CameraSessionHandler.swift
//  PlatformKit
//
//  Created by Abhiraj on 13/12/25.
//

import AVFoundation
import CoreKit
import PlatformKit_api

protocol CameraSessionHandler {
    associatedtype InputHandler: CameraHardwareHandler
    var inputHandler: InputHandler {get}
}

protocol CameraHardwareHandler {
    
}
 
protocol SingleCameraHandler: CameraHardwareHandler {
    var selectedPosition: AVCaptureDevice.Position {set get}
    var audioDevice: AVCaptureDeviceInput? {get}
    var selectedVideoDevice: AVCaptureDeviceInput? {get}
}
