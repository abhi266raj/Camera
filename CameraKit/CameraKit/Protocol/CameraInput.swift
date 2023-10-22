//
//  CameraInput.swift
//  CameraKit
//
//  Created by Abhiraj on 16/10/23.
//

import Foundation
import AVFoundation
import AssetsLibrary
import UIKit
import Photos


public protocol CameraInput {
    func startRunning() async
    func stopRunning() async
    
    var audioDevice: AVCaptureDeviceInput? {get}
    var videoDevice: AVCaptureDeviceInput? {get}
    
    func toggleCamera() async -> Bool 
    
}
