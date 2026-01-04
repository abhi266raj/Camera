//
//  PermissionStatus.swift
//  DomainKit
//
//  Created by Abhiraj on 08/12/25.
//

public protocol PermissionService: Sendable {
    func requestCameraAndMicrophoneIfNeeded() async -> Bool
    
    func requestPhotoAddAccess() async -> Bool
}
