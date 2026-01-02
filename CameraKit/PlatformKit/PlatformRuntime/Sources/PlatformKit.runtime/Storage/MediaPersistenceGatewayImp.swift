//
//  MediaPersistenceGatewayImp.swift
//  CameraKit
//
//  Created by Abhiraj on 02/01/26.
//


import PlatformApi
internal import Photos
import UIKit

struct MediaPersistenceGatewayImp: MediaPersistenceGateway {
    
    let photoLibrary: PHPhotoLibrary
    init(photoLibrary: PHPhotoLibrary = PHPhotoLibrary.shared()) {
        self.photoLibrary = photoLibrary
    }
    
    private func saveImageToPhotoLibrary(_ image: UIImage) async throws {
        try await photoLibrary.performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }
    }

    func saveVideoToPhotoLibrary(_ url: URL) async throws {
        try await photoLibrary.performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }
    }
    
    func saveImageToPhotoLibrary(_ data: Data) async throws {
        try await photoLibrary.performChanges {
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: data, options: nil)
        }
    }
    
}
