//
//  CameraInputImp.swift
//  PlatformKit
//
//  Created by Abhiraj on 12/12/25.
//

import Foundation
import AVFoundation
import UIKit
import PlatformApi


final class CameraInputImp: CameraInput, Sendable {
    
    
    public  init() {
        
    }
    

    
    var audioDevice: AVCaptureDeviceInput? {
        let device =  AVCaptureDevice.default(for: .audio)
        guard let device else {return nil}
        do {
            let input = try AVCaptureDeviceInput(device: device)
            return input
        }catch {
            return nil
        }
    }
    
    var frontCamera: AVCaptureDeviceInput? {
        let device =  AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        guard let device else {return nil}
        do {
            let input = try AVCaptureDeviceInput(device: device)
            return input
        }catch {
            return nil
        }
    }
    
    var backCamera: AVCaptureDeviceInput? {
        let device =  AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        guard let device else {return nil}
        do {
            let input = try AVCaptureDeviceInput(device: device)
            return input
        }catch {
            return nil
        }
    }
        
}
