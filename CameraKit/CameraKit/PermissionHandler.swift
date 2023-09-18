//
//  PermissionHandler.swift
//  CameraKit
//
//  Created by Abhiraj on 17/09/23.
//

import Foundation
import AVFoundation
import AssetsLibrary

protocol PermissionHandler {
    func requestForPermission() async -> Bool
}

struct CameraPermissionHandler: PermissionHandler {
    @MainActor
    func requestForPermission() async -> Bool {
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
}
