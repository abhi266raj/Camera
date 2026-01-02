//
//  MediaPersistenceGateway.swift
//  CameraKit
//
//  Created by Abhiraj on 02/01/26.
//

import Foundation

public protocol MediaPersistenceGateway {
    func saveVideoToPhotoLibrary(_ url: URL) async throws
    func saveImageToPhotoLibrary(_ data: Data) async throws
}

