//
//  MediaPersistenceGatewayImp.swift
//  CameraKit
//
//  Created by Abhiraj on 02/01/26.
//


import PlatformApi
internal import Photos
import UIKit

public struct MediaPersistenceGatewayImp: MediaPersistenceGateway {
    
    let photoLibrary: PHPhotoLibrary
    
    public init() {
        self.init(photoLibrary: PHPhotoLibrary.shared())
    }
    
    init(photoLibrary: PHPhotoLibrary) {
        self.photoLibrary = photoLibrary
    }
    
    private func saveImageToPhotoLibrary(_ image: UIImage) async throws {
        try await photoLibrary.performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }
    }

    public func saveVideoToPhotoLibrary(_ url: URL) async throws {
        try await photoLibrary.performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }
    }
    
    public func saveImageToPhotoLibrary(_ data: Data) async throws {
        try await photoLibrary.performChanges {
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: data, options: nil)
        }
    }
    
}
