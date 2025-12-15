//
//  PermissionStatus.swift
//  DomainKit
//
//  Created by Abhiraj on 08/12/25.
//


import Foundation
import AVFoundation
import Photos

public enum PermissionStatus {
    case unknown
    case authorized
    case denied
}

public protocol PermissionService {
    func requestCameraAndMicrophoneIfNeeded() async -> Bool
    
    func requestPhotoAddAccess() async -> Bool
}
