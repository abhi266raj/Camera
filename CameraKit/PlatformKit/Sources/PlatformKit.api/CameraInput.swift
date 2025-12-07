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
