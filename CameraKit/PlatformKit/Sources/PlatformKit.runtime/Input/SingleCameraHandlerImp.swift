//
//  SingleCameraHandlerImp.swift
//  PlatformKit
//
//  Created by Abhiraj on 13/12/25.
//

import AVFoundation
import CoreKit
import PlatformKit_api


class SingleCameraHandlerImp: SingleCameraHandler {
    var selectedPosition: AVCaptureDevice.Position = .front
    var selectedVideoDevice: AVCaptureDeviceInput? {
        if selectedPosition == .front {
            return frontCamera
        } else {
           return backCamera
        }
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
    
    
    private var frontCamera: AVCaptureDeviceInput? {
        let device =  AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        guard let device else {return nil}
        do {
            let input = try AVCaptureDeviceInput(device: device)
            return input
        }catch {
            return nil
        }
    }
    
    private var backCamera: AVCaptureDeviceInput? {
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
