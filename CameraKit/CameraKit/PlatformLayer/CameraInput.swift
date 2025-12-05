//
//  CameraInput.swift
//  CameraKit
//
//  Created by Abhiraj on 16/10/23.
//

import Foundation
import AVFoundation
import UIKit
import Photos


public protocol CameraInput {
    func startRunning() async
    func stopRunning() async
    
    var audioDevice: AVCaptureDeviceInput? {get}
    var videoDevice: AVCaptureDeviceInput? {get}
    
    func toggleCamera() async -> Bool 
    
}

@CameraInputSessionActor
class CameraInputImp: CameraInput {
    
    var session: AVCaptureSession?
    
    nonisolated init() {
        
    }
    
    func startRunning() {
        session?.startRunning()
    }
    
    func stopRunning() {
        session?.stopRunning()
    }
    
    nonisolated var audioDevice: AVCaptureDeviceInput? {
        let device =  AVCaptureDevice.default(for: .audio)
        guard let device else {return nil}
        do {
            let input = try AVCaptureDeviceInput(device: device)
            return input
        }catch {
            return nil
        }
    }
    
    
    var selectedPosition: AVCaptureDevice.Position = .front
    
    nonisolated var videoDevice:  AVCaptureDeviceInput? {
        frontCamera
    }
    
    nonisolated var frontCamera: AVCaptureDeviceInput? {
        let device =  AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        guard let device else {return nil}
        do {
            let input = try AVCaptureDeviceInput(device: device)
            return input
        }catch {
            return nil
        }
    }
    
    nonisolated var backCamera: AVCaptureDeviceInput? {
        let device =  AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        guard let device else {return nil}
        do {
            let input = try AVCaptureDeviceInput(device: device)
            return input
        }catch {
            return nil
        }
    }
    
    
    
    func toggleCamera()  async -> Bool {
       
        var camera = frontCamera
        if selectedPosition == .front {
            camera = backCamera
            self.selectedPosition = .back
        }else {
            self.selectedPosition = .front
        }
        
       
        guard let camera, let session else {
            return false
        }
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        if let videoInput = session.inputs.first(where: { ($0 as? AVCaptureDeviceInput)?.device.hasMediaType(.video) ?? false }) as? AVCaptureDeviceInput {
            session.removeInput(videoInput)
        }
        if session.canAddInput(camera) {
            session.addInput(camera)
        }
        
        return true
    }
    
}
