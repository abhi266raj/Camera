//
//  CameraSessionHandlerImp.swift
//  PlatformKit
//
//  Created by Abhiraj on 13/12/25.
//

import Foundation
import AVFoundation
import UIKit
import PlatformKit_api

class CameraSessionHandlerImp: CameraSessionHandler, CameraSessionService{
    
    let session: AVCaptureSession
    public init(session: AVCaptureSession) {
        self.session = session
    }
    public func start() async {
        session.startRunning()
    }
    
    public func stop() async {
        session.stopRunning()
    }
    
    public func update(config: CameraInputConfig) async -> Bool {
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        return await updateWithoutCommit(config: config)
        
        
    }
    
    func updateWithoutCommit(config: CameraInputConfig) async -> Bool {
        guard let deviceInput = inputHandler.selectedVideoDevice else {
            return false
        }
        
        if let dimension = config.dimensions {
            let device = deviceInput.device
            let matched = device.formats.first {
                $0.supportedMaxPhotoDimensions.contains { $0.width == dimension.width &&
                    $0.height == dimension.height }
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
    
    
    public func setup(input: [AVCaptureInput], output: [AVCaptureOutput], config: CameraInputConfig) async -> Bool {
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        guard let videoDevice = inputHandler.selectedVideoDevice else {
            return false
        }
        guard let audioDevice = inputHandler.audioDevice else {
            return false
        }
        
        if session.canAddInput(videoDevice) {
            session.addInput(videoDevice)
        }else{
            return false
        }
        
        if session.canAddInput(audioDevice) {
            session.addInput(audioDevice)
        }else{
            return false
        }
        
        for item in input {
            if session.canAddInput(item) {
                session.addInput(item)
            }else{
                return false
            }
        }
        
        for item in output {
            if session.canAddOutput(item) {
                session.addOutput(item)
            }else{
                return false
            }
        }
        
        return await updateWithoutCommit(config: config)
        
    }
    
    public func toggle(config: CameraInputConfig) async -> Bool {
        if inputHandler.selectedPosition == .front {
            inputHandler.selectedPosition = .back
        }else {
            inputHandler.selectedPosition = .front
        }
        return await update(config: config)
    }
    
    var inputHandler = SingleCameraHandlerImp()
}
