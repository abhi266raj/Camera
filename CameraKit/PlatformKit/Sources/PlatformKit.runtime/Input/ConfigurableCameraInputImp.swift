//
//  ConfigurableCameraInputImp.swift
//  CameraKit
//
//  Created by Abhiraj on 16/10/23.
//

import Foundation
import AVFoundation
import UIKit
import PlatformKit_api




@CameraInputSessionActor
public class ConfigurableCameraInputImp: CameraInput, MultiCameraInput {
    
    public var session: AVCaptureSession?
    
    nonisolated public  init() {
    }
    
    public func startRunning() {
        session?.startRunning()
    }
    
    public func stopRunning() {
        session?.stopRunning()
    }
    
    nonisolated public var audioDevice: AVCaptureDeviceInput? {
        let device =  AVCaptureDevice.default(for: .audio)
        guard let device else {return nil}
        do {
            let input = try AVCaptureDeviceInput(device: device)
            return input
        }catch {
            return nil
        }
    }
    
    
    public var selectedPosition: AVCaptureDevice.Position = .front
    
    private var currentUsedVideoDevice: AVCaptureDeviceInput? {
        if selectedPosition == .front {
            return frontCamera
        } else {
           return backCamera
        }
    }
    
    nonisolated public var videoDevice:  AVCaptureDeviceInput? {
        frontCamera
    }
    
    public func configureDeviceFor(config: CameraInputConfig) -> Bool {
        
        guard let deviceInput = currentUsedVideoDevice else {
            return false
        }
        guard let session else {
            return false
        }
        if let dimension = config.dimensions {
            let device = deviceInput.device
            let matched = device.formats.first {
                $0.supportedMaxPhotoDimensions.contains { $0.width == dimension.width &&
                    $0.height == dimension.height }
            }
            
            session.beginConfiguration()
            defer {
                session.commitConfiguration()
            }
            
            
            guard let format = matched else { return false }
            do {
                try device.lockForConfiguration()
                device.activeFormat = format
                device.unlockForConfiguration()
            } catch {
                return false
            }
        }
        
        
        
        if let videoInput = session.inputs.first(where: { ($0 as? AVCaptureDeviceInput)?.device.hasMediaType(.video) ?? false }) as? AVCaptureDeviceInput {
            session.removeInput(videoInput)
        }
        if session.canAddInput(deviceInput) {
            session.addInput(deviceInput)
        }
        
        return true
    }
    
   

    nonisolated public var frontCamera: AVCaptureDeviceInput? {
        let device =  AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        guard let device else {return nil}
        do {
            let input = try AVCaptureDeviceInput(device: device)
            return input
        }catch {
            return nil
        }
    }
    
    nonisolated public var backCamera: AVCaptureDeviceInput? {
        let device =  AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        guard let device else {return nil}
        do {
            let input = try AVCaptureDeviceInput(device: device)
            return input
        }catch {
            return nil
        }
    }
    
    
    
    public func toggleCamera()  async -> Bool {
        
        if selectedPosition == .front {
            self.selectedPosition = .back
        }else {
            self.selectedPosition = .front
        }
        return true
    }
    
}

