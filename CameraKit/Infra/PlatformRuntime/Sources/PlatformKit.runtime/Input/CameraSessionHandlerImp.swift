//
//  CameraSessionHandlerImp.swift
//  PlatformKit
//
//  Created by Abhiraj on 13/12/25.
//

import Foundation
@preconcurrency import AVFoundation
import UIKit
import PlatformApi

final class CameraSessionHandlerImp:  CameraSessionService{
    public init() {
    }
}


extension CameraSessionHandlerImp {
    
    enum SessionHandlerError: Error {
        case InvalidConfig
    }
    
    func apply(_ config: SessionConfig, session: AVCaptureSession) async throws {
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        
        removeOldContent(session)
        
        for item in config.videoDevice {
            if session.canAddInput(item) {
                session.addInput(item)
            }else{
                throw SessionHandlerError.InvalidConfig
            }

        }
        
        for item in config.audioDevice {
            if session.canAddInput(item) {
                session.addInput(item)
            }else{
                throw SessionHandlerError.InvalidConfig
            }
        }
        
        for item in config.contentOutput{
            if session.canAddOutput(item) {
                session.addOutput(item)
            }else{
                throw SessionHandlerError.InvalidConfig
            }
        }
        
        if let dimension = config.videoResolution {
            for item in config.videoDevice {
                try update(device: item.device, dimension: dimension)
            }
        }
        
    }
    
    private func removeOldContent(_ session: AVCaptureSession) {
        for item in session.inputs {
            session.removeInput(item)
        }
        
        for item in session.outputs {
            session.removeOutput(item)
        }
    }
    
    private func update(device: AVCaptureDevice, dimension: CMVideoDimensions)  throws{
        let matched = device.formats.first {
            $0.supportedMaxPhotoDimensions.contains { $0.width == dimension.width &&
                $0.height == dimension.height }
        }
        
        guard let format = matched else { throw SessionHandlerError.InvalidConfig }
        
        try device.lockForConfiguration()
        device.activeFormat = format
        device.unlockForConfiguration()
    }
    
    
}
