//  PermissionServiceImp.swift
//  CameraKit
//  Created by Abhiraj on 17/09/23.

import AVFoundation
internal import Photos
import DomainApi

struct PermissionServiceImp: PermissionService {
    public init() {}
    
    @MainActor
    public func requestCameraAndMicrophoneIfNeeded() async -> Bool {
        let videoPermission = await AVCaptureDevice.requestAccess(for: .video)
        guard videoPermission else { return false }
        let audioPermission = await AVCaptureDevice.requestAccess(for: .audio)
        guard audioPermission else { return false }
        return true
    }
    
    public func requestPhotoAddAccess() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        switch status {
        case .authorized, .restricted, .limited:
            return true
        case .notDetermined, .denied:
            return false
        @unknown default:
            return false
        }
    }
}
