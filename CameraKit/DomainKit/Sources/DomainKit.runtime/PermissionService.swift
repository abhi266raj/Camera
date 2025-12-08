//
//  PermissionHandler.swift
//  CameraKit
//
//  Created by Abhiraj on 17/09/23.
//

import Foundation
import AVFoundation
import Photos
import DomainKit_api

public struct CameraPermissionService: PermissionService {
    
    public init(){
        
    }
    
    @MainActor
    public func requestCameraAndMicrophoneIfNeeded() async -> Bool {
        let videoPermission = await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { (granted: Bool) in
                continuation.resume(returning: granted)
            }
        }
        guard videoPermission == true else { return false }
        
        let audioPermission = await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .audio) { (granted: Bool) in
                continuation.resume(returning: granted)
            }
        }
        guard audioPermission == true else { return false }
       
        return true
    }
    
    public func requestPhotoAddAccess() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return false
        case .restricted:
            return true
        case .denied:
            return false
        case .limited:
            return true
        @unknown default:
            return false
        }
    }
}

